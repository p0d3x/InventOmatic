 
package
{
   import flash.display.MovieClip;
   
   public class DamageNumberClip extends MovieClip
   {
       
      
      public var ParentObj:DamageNumbers;
      
      public var UniqueId:int;
      
      public var Base_mc:MovieClip;
      
      public var Crit_mc:MovieClip;
      
      public function DamageNumberClip()
      {
         // method body index: 846 method index: 846
         super();
      }
      
      public function Destroy() : *
      {
         // method body index: 847 method index: 847
         this.ParentObj.RemoveDamageNumber(this.UniqueId);
      }
   }
}
