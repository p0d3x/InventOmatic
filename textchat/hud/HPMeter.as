 
package
{
   public dynamic class HPMeter extends HealthMeter
   {
       
      
      public function HPMeter()
      {
         // method body index: 3416 method index: 3416
         super();
         this.__setProp_Optional_mc_HPMeter_Optional_mc_0();
         this.__setProp_RadsBar_mc_HPMeter_RadsBar_mc_0();
      }
      
      function __setProp_Optional_mc_HPMeter_Optional_mc_0() : *
      {
         // method body index: 3417 method index: 3417
         try
         {
            Optional_mc["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         Optional_mc.BarAlpha = 0.5;
         Optional_mc.bracketCornerLength = 6;
         Optional_mc.bracketLineWidth = 1.5;
         Optional_mc.bracketPaddingX = 0;
         Optional_mc.bracketPaddingY = 0;
         Optional_mc.BracketStyle = "horizontal";
         Optional_mc.bShowBrackets = false;
         Optional_mc.bUseShadedBackground = false;
         Optional_mc.Justification = "left";
         Optional_mc.Percent = 0;
         Optional_mc.ShadedBackgroundMethod = "Shader";
         Optional_mc.ShadedBackgroundType = "normal";
         try
         {
            Optional_mc["componentInspectorSetting"] = false;
            return;
         }
         catch(e:Error)
         {
            return;
         }
      }
      
      function __setProp_RadsBar_mc_HPMeter_RadsBar_mc_0() : *
      {
         // method body index: 3418 method index: 3418
         try
         {
            RadsBar_mc["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         RadsBar_mc.BarAlpha = 1;
         RadsBar_mc.bracketCornerLength = 6;
         RadsBar_mc.bracketLineWidth = 1.5;
         RadsBar_mc.bracketPaddingX = 0;
         RadsBar_mc.bracketPaddingY = 0;
         RadsBar_mc.BracketStyle = "horizontal";
         RadsBar_mc.bShowBrackets = false;
         RadsBar_mc.bUseShadedBackground = false;
         RadsBar_mc.Justification = "right";
         RadsBar_mc.Percent = 1;
         RadsBar_mc.ShadedBackgroundMethod = "Flash";
         RadsBar_mc.ShadedBackgroundType = "normal";
         try
         {
            RadsBar_mc["componentInspectorSetting"] = false;
            return;
         }
         catch(e:Error)
         {
            return;
         }
      }
   }
}
