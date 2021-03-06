/*
###############################################################################
#cyn.in is an open source Collaborative Knowledge Management Appliance that 
#enables teams to seamlessly work together on files, documents and content in 
#a secure central environment.
#
#cyn.in v2 an open source appliance is distributed under the GPL v3 license 
#along with commercial support options.
#
#cyn.in is a Cynapse Invention.
#
#Copyright (C) 2008 Cynapse India Pvt. Ltd.
#
#This program is free software: you can redistribute it and/or modify it under
#the terms of the GNU General Public License as published by the Free Software 
#Foundation, either version 3 of the License, or any later version and observe 
#the Additional Terms applicable to this program and must display appropriate 
#legal notices. In accordance with Section 7(b) of the GNU General Public 
#License version 3, these Appropriate Legal Notices must retain the display of 
#the "Powered by cyn.in" AND "A Cynapse Invention" logos. You should have 
#received a copy of the detailed Additional Terms License with this program.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of 
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General 
#Public License for more details.
#
#You should have received a copy of the GNU General Public License along with 
#this program.  If not, see <http://www.gnu.org/licenses/>.
#
#You can contact Cynapse at support@cynapse.com with any problems with cyn.in. 
#For any queries regarding the licensing, please send your mails to 
# legal@cynapse.com
#
#You can also contact Cynapse at:
#802, Building No. 1,
#Dheeraj Sagar, Malad(W)
#Mumbai-400064, India
###############################################################################
*/
package model.updates
{
	import flash.events.Event;

	public class updateitemevent extends Event
	{
		
		/**
		 * Event type for an item is added.
		 */
		static public const ADDED: String = "updateitemadded";
		
		/**
		 * Event type for an item is updated.
		 */
		static public const UPDATED: String = "updateitemupdated";

		/**
		 * Event type for an item is updated.
		 */
		static public const SELECTED: String = "updateitemselected";

		static public const REMOVED: String = "updateitemremoved";
		
		/**
		 * The item for which this event has happened
		 * */
		 public var item:BaseItem;
		 
		 
		 public var oldindex:int;
		
		public function updateitemevent(type:String, foritem:BaseItem, olditemindex:int = -1)
		{
			this.oldindex = olditemindex;
			this.item = foritem;
			super(type);
		}
		
		override public function clone():Event
		{
			return new updateitemevent(this.type,this.item,this.oldindex);
		}
		
	}
}