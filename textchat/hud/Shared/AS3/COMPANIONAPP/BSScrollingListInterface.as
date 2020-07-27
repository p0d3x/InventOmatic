 
package Shared.AS3.COMPANIONAPP
{
   import Mobile.ScrollList.MobileScrollList;
   
   public class BSScrollingListInterface
   {
      
      public static const STATS_SPECIAL_ENTRY_LINKAGE_ID:String = // method body index: 277 method index: 277
      "SPECIALListEntry";
      
      public static const STATS_PERKS_ENTRY_LINKAGE_ID:String = // method body index: 277 method index: 277
      "PerksListEntry";
      
      public static const INVENTORY_ENTRY_LINKAGE_ID:String = // method body index: 277 method index: 277
      "InvListEntry";
      
      public static const INVENTORY_COMPONENT_ENTRY_LINKAGE_ID:String = // method body index: 277 method index: 277
      "ComponentListEntry";
      
      public static const INVENTORY_COMPONENT_OWNERS_ENTRY_LINKAGE_ID:String = // method body index: 277 method index: 277
      "ComponentOwnersListEntry";
      
      public static const DATA_STATS_CATEGORIES_ENTRY_LINKAGE_ID:String = // method body index: 277 method index: 277
      "Stats_CategoriesListEntry";
      
      public static const DATA_STATS_VALUES_ENTRY_LINKAGE_ID:String = // method body index: 277 method index: 277
      "Stats_ValuesListEntry";
      
      public static const DATA_WORKSHOPS_ENTRY_LINKAGE_ID:String = // method body index: 277 method index: 277
      "WorkshopsListEntry";
      
      public static const QUEST_ENTRY_LINKAGE_ID:String = // method body index: 277 method index: 277
      "QuestsListEntry";
      
      public static const QUEST_OBJECTIVES_ENTRY_LINKAGE_ID:String = // method body index: 277 method index: 277
      "ObjectivesListEntry";
      
      public static const RADIO_ENTRY_LINKAGE_ID:String = // method body index: 277 method index: 277
      "RadioListEntry";
      
      public static const PIPBOY_MESSAGE_ENTRY_LINKAGE_ID:String = // method body index: 277 method index: 277
      "MessageBoxButtonEntry";
      
      public static const STATS_SPECIAL_RENDERER_LINKAGE_ID:String = // method body index: 277 method index: 277
      "SPECIALItemRendererMc";
      
      public static const STATS_PERKS_RENDERER_LINKAGE_ID:String = // method body index: 277 method index: 277
      "PerksItemRendererMc";
      
      public static const INVENTORY_RENDERER_LINKAGE_ID:String = // method body index: 277 method index: 277
      "InventoryItemRendererMc";
      
      public static const INVENTORY_COMPONENT_OWNERS_RENDERER_LINKAGE_ID:String = // method body index: 277 method index: 277
      "ComponentOwnersItemRendererMc";
      
      public static const DATA_STATS_CATEGORIES_RENDERER_LINKAGE_ID:String = // method body index: 277 method index: 277
      "StatsCategoriesItemRendererMc";
      
      public static const DATA_STATS_VALUES_RENDERER_LINKAGE_ID:String = // method body index: 277 method index: 277
      "StatsValuesItemRendererMc";
      
      public static const DATA_WORKSHOPS_RENDERER_LINKAGE_ID:String = // method body index: 277 method index: 277
      "WorkshopsItemRendererMc";
      
      public static const QUEST_RENDERER_LINKAGE_ID:String = // method body index: 277 method index: 277
      "QuestsItemRendererMc";
      
      public static const QUEST_OBJECTIVES_RENDERER_LINKAGE_ID:String = // method body index: 277 method index: 277
      "QuestsObjectivesItemRendererMc";
      
      public static const RADIO_RENDERER_LINKAGE_ID:String = // method body index: 277 method index: 277
      "RadioItemRendererMc";
      
      public static const PIPBOY_MESSAGE_RENDERER_LINKAGE_ID:String = // method body index: 277 method index: 277
      "PipboyMessageItemRenderer";
       
      
      public function BSScrollingListInterface()
      {
         // method body index: 279 method index: 279
         super();
      }
      
      public static function GetMobileScrollListProperties(param1:String) : MobileScrollListProperties
      {
         // method body index: 278 method index: 278
         var _loc2_:MobileScrollListProperties = new MobileScrollListProperties();
         switch(param1)
         {
            case STATS_SPECIAL_ENTRY_LINKAGE_ID:
               _loc2_.linkageId = STATS_SPECIAL_RENDERER_LINKAGE_ID;
               _loc2_.maskDimension = 450;
               _loc2_.scrollDirection = MobileScrollList.VERTICAL;
               _loc2_.spaceBetweenButtons = 0;
               _loc2_.clickable = true;
               _loc2_.reversed = false;
               break;
            case STATS_PERKS_ENTRY_LINKAGE_ID:
               _loc2_.linkageId = STATS_PERKS_RENDERER_LINKAGE_ID;
               _loc2_.maskDimension = 400;
               _loc2_.scrollDirection = MobileScrollList.VERTICAL;
               _loc2_.spaceBetweenButtons = 0;
               _loc2_.clickable = true;
               _loc2_.reversed = false;
               break;
            case INVENTORY_COMPONENT_ENTRY_LINKAGE_ID:
            case INVENTORY_ENTRY_LINKAGE_ID:
               _loc2_.linkageId = INVENTORY_RENDERER_LINKAGE_ID;
               _loc2_.maskDimension = 405;
               _loc2_.scrollDirection = MobileScrollList.VERTICAL;
               _loc2_.spaceBetweenButtons = 0;
               _loc2_.clickable = true;
               _loc2_.reversed = false;
               break;
            case INVENTORY_COMPONENT_OWNERS_ENTRY_LINKAGE_ID:
               _loc2_.linkageId = INVENTORY_COMPONENT_OWNERS_RENDERER_LINKAGE_ID;
               _loc2_.maskDimension = 400;
               _loc2_.scrollDirection = MobileScrollList.VERTICAL;
               _loc2_.spaceBetweenButtons = 0;
               _loc2_.clickable = true;
               _loc2_.reversed = false;
               break;
            case DATA_STATS_CATEGORIES_ENTRY_LINKAGE_ID:
               _loc2_.linkageId = DATA_STATS_CATEGORIES_RENDERER_LINKAGE_ID;
               _loc2_.maskDimension = 400;
               _loc2_.scrollDirection = MobileScrollList.VERTICAL;
               _loc2_.spaceBetweenButtons = 2.25;
               _loc2_.clickable = true;
               _loc2_.reversed = false;
               break;
            case DATA_STATS_VALUES_ENTRY_LINKAGE_ID:
               _loc2_.linkageId = DATA_STATS_VALUES_RENDERER_LINKAGE_ID;
               _loc2_.maskDimension = 400;
               _loc2_.scrollDirection = MobileScrollList.VERTICAL;
               _loc2_.spaceBetweenButtons = 2.75;
               _loc2_.clickable = false;
               _loc2_.reversed = false;
               break;
            case DATA_WORKSHOPS_ENTRY_LINKAGE_ID:
               _loc2_.linkageId = DATA_WORKSHOPS_RENDERER_LINKAGE_ID;
               _loc2_.maskDimension = 400;
               _loc2_.scrollDirection = MobileScrollList.VERTICAL;
               _loc2_.spaceBetweenButtons = 2.75;
               _loc2_.clickable = true;
               _loc2_.reversed = false;
               break;
            case QUEST_ENTRY_LINKAGE_ID:
               _loc2_.linkageId = QUEST_RENDERER_LINKAGE_ID;
               _loc2_.maskDimension = 400;
               _loc2_.scrollDirection = MobileScrollList.VERTICAL;
               _loc2_.spaceBetweenButtons = 1.4;
               _loc2_.clickable = true;
               _loc2_.reversed = false;
               break;
            case QUEST_OBJECTIVES_ENTRY_LINKAGE_ID:
               _loc2_.linkageId = QUEST_OBJECTIVES_RENDERER_LINKAGE_ID;
               _loc2_.maskDimension = 200;
               _loc2_.scrollDirection = MobileScrollList.VERTICAL;
               _loc2_.spaceBetweenButtons = 1.75;
               _loc2_.clickable = false;
               _loc2_.reversed = false;
               break;
            case RADIO_ENTRY_LINKAGE_ID:
               _loc2_.linkageId = RADIO_RENDERER_LINKAGE_ID;
               _loc2_.maskDimension = 400;
               _loc2_.scrollDirection = MobileScrollList.VERTICAL;
               _loc2_.spaceBetweenButtons = 1.4;
               _loc2_.clickable = true;
               _loc2_.reversed = false;
               break;
            case PIPBOY_MESSAGE_ENTRY_LINKAGE_ID:
               _loc2_.linkageId = PIPBOY_MESSAGE_RENDERER_LINKAGE_ID;
               _loc2_.maskDimension = 150;
               _loc2_.scrollDirection = MobileScrollList.VERTICAL;
               _loc2_.spaceBetweenButtons = 4;
               _loc2_.clickable = true;
               _loc2_.reversed = false;
               break;
            default:
               trace("Error: No mapping found between ListItemRenderer \'" + param1 + "\' used InGame and mobile ListItemRenderer");
         }
         return _loc2_;
      }
   }
}
