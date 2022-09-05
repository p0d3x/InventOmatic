package utils {
public class MatchingUtil {
    public function MatchingUtil() {
    }

    public static function isMatchingString(itemName:String, stringToCompare:String, matchMode:String):Boolean {
        if (itemName.length < 1 || stringToCompare.length < 1) {
            return false;
        }
        try {
            if (matchMode === MatchMode.EXACT) {
                return itemName === stringToCompare;
            } else if (matchMode === MatchMode.CONTAINS) {
                return itemName.indexOf(stringToCompare) >= 0;
            } else if (matchMode === MatchMode.STARTS) {
                return itemName.indexOf(stringToCompare) === 0;
            } else if (matchMode === MatchMode.ALL) {
                return true;
            }
        } catch (e:Error) {
            Logger.get().error("Error checking string match mode: {0}", e);
        }
        return false;
    }
}
}
