 
package HUDMenu_fla
{
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public dynamic class none2command_167 extends MovieClip
   {
       
      
      public var Down:MovieClip;
      
      public var Left:MovieClip;
      
      public var Right:MovieClip;
      
      public var Up:MovieClip;
      
      public function none2command_167()
      {
         // method body index: 1579 method index: 1579
         super();
         addFrameScript(0,this.frame1,5,this.frame6);
      }
      
      function frame1() : *
      {
         // method body index: 1580 method index: 1580
         stop();
      }
      
      function frame6() : *
      {
         // method body index: 1581 method index: 1581
         dispatchEvent(new Event("animationComplete"));
      }
   }
}
