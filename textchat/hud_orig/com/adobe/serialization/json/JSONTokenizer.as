 
package com.adobe.serialization.json
{
   public class JSONTokenizer
   {
       
      
      private var strict:Boolean;
      
      private var obj:Object;
      
      private var jsonString:String;
      
      private var loc:int;
      
      private var ch:String;
      
      private const controlCharsRegExp:RegExp = // method body index: 337 method index: 337
      /[\x00-\x1F]/;
      
      public function JSONTokenizer(s:String, strict:Boolean)
      {
         // method body index: 337 method index: 337
         super();
         this.jsonString = s;
         this.strict = strict;
         this.loc = 0;
         this.nextChar();
      }
      
      public function getNextToken() : JSONToken
      {
         // method body index: 338 method index: 338
         var possibleTrue:String = null;
         var possibleFalse:String = null;
         var possibleNull:String = null;
         var possibleNaN:String = null;
         var token:JSONToken = null;
         this.skipIgnored();
         switch(this.ch)
         {
            case "{":
               token = JSONToken.create(JSONTokenType.LEFT_BRACE,this.ch);
               this.nextChar();
               break;
            case "}":
               token = JSONToken.create(JSONTokenType.RIGHT_BRACE,this.ch);
               this.nextChar();
               break;
            case "[":
               token = JSONToken.create(JSONTokenType.LEFT_BRACKET,this.ch);
               this.nextChar();
               break;
            case "]":
               token = JSONToken.create(JSONTokenType.RIGHT_BRACKET,this.ch);
               this.nextChar();
               break;
            case ",":
               token = JSONToken.create(JSONTokenType.COMMA,this.ch);
               this.nextChar();
               break;
            case ":":
               token = JSONToken.create(JSONTokenType.COLON,this.ch);
               this.nextChar();
               break;
            case "t":
               possibleTrue = "t" + this.nextChar() + this.nextChar() + this.nextChar();
               if(possibleTrue == "true")
               {
                  token = JSONToken.create(JSONTokenType.TRUE,true);
                  this.nextChar();
               }
               else
               {
                  this.parseError("Expecting \'true\' but found " + possibleTrue);
               }
               break;
            case "f":
               possibleFalse = "f" + this.nextChar() + this.nextChar() + this.nextChar() + this.nextChar();
               if(possibleFalse == "false")
               {
                  token = JSONToken.create(JSONTokenType.FALSE,false);
                  this.nextChar();
               }
               else
               {
                  this.parseError("Expecting \'false\' but found " + possibleFalse);
               }
               break;
            case "n":
               possibleNull = "n" + this.nextChar() + this.nextChar() + this.nextChar();
               if(possibleNull == "null")
               {
                  token = JSONToken.create(JSONTokenType.NULL,null);
                  this.nextChar();
               }
               else
               {
                  this.parseError("Expecting \'null\' but found " + possibleNull);
               }
               break;
            case "N":
               possibleNaN = "N" + this.nextChar() + this.nextChar();
               if(possibleNaN == "NaN")
               {
                  token = JSONToken.create(JSONTokenType.NAN,NaN);
                  this.nextChar();
               }
               else
               {
                  this.parseError("Expecting \'NaN\' but found " + possibleNaN);
               }
               break;
            case "\"":
               token = this.readString();
               break;
            default:
               if(this.isDigit(this.ch) || this.ch == "-")
               {
                  token = this.readNumber();
               }
               else if(this.ch == "")
               {
                  token = null;
               }
               else
               {
                  this.parseError("Unexpected " + this.ch + " encountered");
               }
         }
         return token;
      }
      
      private final function readString() : JSONToken
      {
         // method body index: 339 method index: 339
         var backspaceCount:int = 0;
         var backspaceIndex:int = 0;
         var quoteIndex:int = this.loc;
         while(true)
         {
            quoteIndex = this.jsonString.indexOf("\"",quoteIndex);
            if(quoteIndex >= 0)
            {
               backspaceCount = 0;
               backspaceIndex = quoteIndex - 1;
               while(this.jsonString.charAt(backspaceIndex) == "\\")
               {
                  backspaceCount++;
                  backspaceIndex--;
               }
               if((backspaceCount & 1) == 0)
               {
                  break;
               }
               quoteIndex++;
            }
            else
            {
               this.parseError("Unterminated string literal");
            }
         }
         var token:JSONToken = JSONToken.create(JSONTokenType.STRING,this.unescapeString(this.jsonString.substr(this.loc,quoteIndex - this.loc)));
         this.loc = quoteIndex + 1;
         this.nextChar();
         return token;
      }
      
      public function unescapeString(input:String) : String
      {
         // method body index: 340 method index: 340
         var nextSubstringStartPosition:int = 0;
         var escapedChar:String = null;
         var hexValue:String = null;
         var unicodeEndPosition:int = 0;
         var i:int = 0;
         var possibleHexChar:String = null;
         if(this.strict && this.controlCharsRegExp.test(input))
         {
            this.parseError("String contains unescaped control character (0x00-0x1F)");
         }
         var result:* = "";
         var backslashIndex:int = 0;
         nextSubstringStartPosition = 0;
         var len:int = input.length;
         while(true)
         {
            backslashIndex = input.indexOf("\\",nextSubstringStartPosition);
            if(backslashIndex >= 0)
            {
               result = result + input.substr(nextSubstringStartPosition,backslashIndex - nextSubstringStartPosition);
               nextSubstringStartPosition = backslashIndex + 2;
               escapedChar = input.charAt(backslashIndex + 1);
               switch(escapedChar)
               {
                  case "\"":
                     result = result + escapedChar;
                     break;
                  case "\\":
                     result = result + escapedChar;
                     break;
                  case "n":
                     result = result + "\n";
                     break;
                  case "r":
                     result = result + "\r";
                     break;
                  case "t":
                     result = result + "\t";
                     break;
                  case "u":
                     hexValue = "";
                     unicodeEndPosition = nextSubstringStartPosition + 4;
                     if(unicodeEndPosition > len)
                     {
                        this.parseError("Unexpected end of input.  Expecting 4 hex digits after \\u.");
                     }
                     for(i = nextSubstringStartPosition; i < unicodeEndPosition; i++)
                     {
                        possibleHexChar = input.charAt(i);
                        if(!this.isHexDigit(possibleHexChar))
                        {
                           this.parseError("Excepted a hex digit, but found: " + possibleHexChar);
                        }
                        hexValue = hexValue + possibleHexChar;
                     }
                     result = result + String.fromCharCode(parseInt(hexValue,16));
                     nextSubstringStartPosition = unicodeEndPosition;
                     break;
                  case "f":
                     result = result + "\f";
                     break;
                  case "/":
                     result = result + "/";
                     break;
                  case "b":
                     result = result + "\b";
                     break;
                  default:
                     result = result + ("\\" + escapedChar);
               }
               if(nextSubstringStartPosition >= len)
               {
                  break;
               }
               continue;
            }
            result = result + input.substr(nextSubstringStartPosition);
            break;
         }
         return result;
      }
      
      private final function readNumber() : JSONToken
      {
         // method body index: 341 method index: 341
         var input:* = "";
         if(this.ch == "-")
         {
            input = input + "-";
            this.nextChar();
         }
         if(!this.isDigit(this.ch))
         {
            this.parseError("Expecting a digit");
         }
         if(this.ch == "0")
         {
            input = input + this.ch;
            this.nextChar();
            if(this.isDigit(this.ch))
            {
               this.parseError("A digit cannot immediately follow 0");
            }
            else if(!this.strict && this.ch == "x")
            {
               input = input + this.ch;
               this.nextChar();
               if(this.isHexDigit(this.ch))
               {
                  input = input + this.ch;
                  this.nextChar();
               }
               else
               {
                  this.parseError("Number in hex format require at least one hex digit after \"0x\"");
               }
               while(this.isHexDigit(this.ch))
               {
                  input = input + this.ch;
                  this.nextChar();
               }
            }
         }
         else
         {
            while(this.isDigit(this.ch))
            {
               input = input + this.ch;
               this.nextChar();
            }
         }
         if(this.ch == ".")
         {
            input = input + ".";
            this.nextChar();
            if(!this.isDigit(this.ch))
            {
               this.parseError("Expecting a digit");
            }
            while(this.isDigit(this.ch))
            {
               input = input + this.ch;
               this.nextChar();
            }
         }
         if(this.ch == "e" || this.ch == "E")
         {
            input = input + "e";
            this.nextChar();
            if(this.ch == "+" || this.ch == "-")
            {
               input = input + this.ch;
               this.nextChar();
            }
            if(!this.isDigit(this.ch))
            {
               this.parseError("Scientific notation number needs exponent value");
            }
            while(this.isDigit(this.ch))
            {
               input = input + this.ch;
               this.nextChar();
            }
         }
         var num:Number = Number(input);
         if(isFinite(num) && !isNaN(num))
         {
            return JSONToken.create(JSONTokenType.NUMBER,num);
         }
         this.parseError("Number " + num + " is not valid!");
         return null;
      }
      
      private final function nextChar() : String
      {
         // method body index: 342 method index: 342
         return this.ch = this.jsonString.charAt(this.loc++);
      }
      
      private final function skipIgnored() : void
      {
         // method body index: 343 method index: 343
         var originalLoc:int = 0;
         do
         {
            originalLoc = this.loc;
            this.skipWhite();
            this.skipComments();
         }
         while(originalLoc != this.loc);
         
      }
      
      private function skipComments() : void
      {
         // method body index: 344 method index: 344
         if(this.ch == "/")
         {
            this.nextChar();
            switch(this.ch)
            {
               case "/":
                  do
                  {
                     this.nextChar();
                  }
                  while(this.ch != "\n" && this.ch != "");
                  
                  this.nextChar();
                  break;
               case "*":
                  this.nextChar();
                  while(true)
                  {
                     if(this.ch == "*")
                     {
                        this.nextChar();
                        if(this.ch == "/")
                        {
                           break;
                        }
                     }
                     else
                     {
                        this.nextChar();
                     }
                     if(this.ch == "")
                     {
                        this.parseError("Multi-line comment not closed");
                     }
                  }
                  this.nextChar();
                  break;
               default:
                  this.parseError("Unexpected " + this.ch + " encountered (expecting \'/\' or \'*\' )");
            }
         }
      }
      
      private final function skipWhite() : void
      {
         // method body index: 345 method index: 345
         while(this.isWhiteSpace(this.ch))
         {
            this.nextChar();
         }
      }
      
      private final function isWhiteSpace(ch:String) : Boolean
      {
         // method body index: 346 method index: 346
         if(ch == " " || ch == "\t" || ch == "\n" || ch == "\r")
         {
            return true;
         }
         if(!this.strict && ch.charCodeAt(0) == 160)
         {
            return true;
         }
         return false;
      }
      
      private final function isDigit(ch:String) : Boolean
      {
         // method body index: 347 method index: 347
         return ch >= "0" && ch <= "9";
      }
      
      private final function isHexDigit(ch:String) : Boolean
      {
         // method body index: 348 method index: 348
         return this.isDigit(ch) || ch >= "A" && ch <= "F" || ch >= "a" && ch <= "f";
      }
      
      public final function parseError(message:String) : void
      {
         // method body index: 349 method index: 349
         throw new JSONParseError(message,this.loc,this.jsonString);
      }
   }
}
