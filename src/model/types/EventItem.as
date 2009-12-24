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
package model.types
{
	import model.logger.Logger;
	import model.updates.BaseItem;
	import model.updates.UpdateItem;
	import model.updates.updatemodel;
	
	import mx.collections.ItemResponder;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;

	public class EventItem extends UpdateItem
	{
		[Bindable] public var startdatetime:Date = null;
		[Bindable] public var enddatetime:Date = null;
		[Bindable] public var location: String = "";
		[Bindable] public var contactName: String = "";
		[Bindable] public var contactEmail: String = "";
		[Bindable] public var contactPhone: String = "";
		[Bindable] public var Attendees:Array = null;
		[Bindable] public var bodyhtml:String = "";
		
		public function EventItem(iteminfo:BaseItem)
		{
			super(iteminfo);
			updatemodel.instance._xserver.getEventInfo(itemuid).addResponder(new ItemResponder(handleEventResponse, handleEventFaultResponse));
		}
		
		public function handleEventResponse(event:ResultEvent, token : AsyncToken = null):void
		{
			startdatetime = event.result.start;
			enddatetime = event.result.end;
			location = event.result.location;
			contactEmail = event.result.contactEmail;
			contactName = event.result.contactName;
			contactPhone = event.result.contactPhone;
			Attendees = event.result.attendees;
            bodyhtml = event.result.bodyhtml.toString();
			Logger.instance.log("Got event detail response from Server" + this);
		}
		public function handleEventFaultResponse(event:FaultEvent, token : AsyncToken = null):void
		{
            Logger.instance.log("Could not fetch Event details: " + event.fault.message, Logger.SEVERITY_SERIOUS);
		}
		override public function toString():String
		{
			return super.toString() + startdatetime + enddatetime + location + contactEmail + contactName + contactPhone + Attendees + bodyhtml;
		}
	}
}