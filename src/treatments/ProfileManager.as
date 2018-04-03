package treatments
{
	import flash.utils.Dictionary;
	
	import database.Database;
	
	import utils.UniqueId;

	public class ProfileManager
	{
		public static var insulinsList:Array = [];
		private static var insulinsMap:Dictionary = new Dictionary();
		
		public function ProfileManager()
		{
			throw new Error("ProfileManager is not meant to be instantiated!");
		}
		
		public static function init():void
		{
			var dbInsulines:Array = Database.getInsulinsSynchronous();
			if (dbInsulines != null && dbInsulines.length > 0)
			{
				for (var i:int = 0; i < dbInsulines.length; i++) 
				{
					var dbInsulin:Object = dbInsulines[i] as Object;
					if (dbInsulin == null)
						continue;
					
					var insulin:Insulin = new Insulin
					(
						dbInsulin.id,
						dbInsulin.name,
						dbInsulin.dia,
						dbInsulin.type,
						dbInsulin.lastmodifiedtimestamp
					);
					
					insulinsList.push(insulin);
					insulinsMap[dbInsulin.id] = insulin;
				}
				insulinsList.sortOn(["name"], Array.CASEINSENSITIVE);
			}
		}
		
		public static function getInsulin(ID:String):Insulin
		{
			var insulinMatched:Insulin;
			
			for (var i:int = 0; i < insulinsList.length; i++) 
			{
				var insulin:Insulin = insulinsList[i] as Insulin;
				if (insulin == null)
					continue;
				
				if (insulin.ID == ID)
				{
					insulinMatched = insulin;
					break;
				}
			}
			
			return insulinMatched;
		}
		
		public static function addInsulin(name:String, dia:Number, type:String, insulinID:String = null, saveToDatabase:Boolean = true):void
		{
			//Generate insulin ID
			var newInsulinID:String = insulinID == null ? UniqueId.createEventId() : insulinID;
			
			//Check duplicates
			if (insulinsMap[newInsulinID] != null)
				return;
			
			//Create new insulin
			var insulin:Insulin = new Insulin
			(
				newInsulinID,
				name,
				dia,
				type,
				new Date().valueOf()
			);
			
			//Add to Spike
			insulinsList.push(insulin);
			insulinsList.sortOn(["name"], Array.CASEINSENSITIVE);
			insulinsMap[newInsulinID] = insulin;
			
			//Save in database
			if (saveToDatabase)
				Database.insertInsulinSynchronous(insulin);
		}
	}
}