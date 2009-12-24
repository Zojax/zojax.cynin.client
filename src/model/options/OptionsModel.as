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
package model.options
{
	import flash.data.EncryptedLocalStore;
	import flash.desktop.NativeApplication;
	import flash.display.Screen;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	
	import model.logger.Logger;
	import model.updates.StringConstants;
	import model.updates.updatemodel;
	
	import mx.core.Application;

	public class OptionsModel extends EventDispatcher
	{
		private static var _instance:OptionsModel = new OptionsModel();
		
		
		private var _startup:Boolean = false;
		private var _autoShow:Boolean = StringConstants.DEFAULT_AUTO_SHOW;
		private var _alwaysontop:Boolean = StringConstants.DEFAULT_ALWAYS_ON_TOP;
		private var _showintaskbar:Boolean = StringConstants.DEFAULT_SHOW_IN_TASKBAR;
		
		private var _currentScreenIndex:int = -1;
		
		
		public function get currentScreenIndex():int
		{
			var baScInd:ByteArray = EncryptedLocalStore.getItem(StringConstants.ELS_SCREEN_INDEX);
			if (baScInd != null)
			{
				_currentScreenIndex = baScInd.readInt();
			}
			return _currentScreenIndex;
		}
		public function set currentScreenIndex(newind:int):void
		{
			if (newind >= 0 && newind < Screen.screens.length )
			{
				_currentScreenIndex = newind;
				var baScreenIndex:ByteArray = new ByteArray();
				baScreenIndex.writeInt(newind);
				EncryptedLocalStore.setItem(StringConstants.ELS_SCREEN_INDEX,baScreenIndex);
				dispatchEvent(new OptionsEvent(OptionsEvent.OPTIONS_SCREEN_CHANGED));
			}
		}
		
		public function get StartOnLogon():Boolean
		{
			var baStartup:ByteArray = EncryptedLocalStore.getItem(StringConstants.ELS_START_ON_LOGON);
			if (baStartup != null)
			{
				Logger.instance.log("Start is stored as " + baStartup.readBoolean() + " in ELS.",Logger.SEVERITY_DEBUG);
				return baStartup.readBoolean();
			}
			else
			{
				Logger.instance.log("Initializing Start On Logon to true as default.",Logger.SEVERITY_DEBUG);
				return true;
			}
		}
		
		public function OptionsCompleted():void
		{
			dispatchEvent(new OptionsEvent(OptionsEvent.OPTIONS_COMPLETED));
		}
		
		[Bindable] public function get UpdateFrequency():Number
		{
			var iFreq:int = StringConstants.DEFAULT_FREQUENCY;
			var baFreq:ByteArray = EncryptedLocalStore.getItem(StringConstants.ELS_UPDATE_FREQUENCY);
			if (baFreq != null) iFreq = baFreq.readInt();
			return iFreq;
		}
		
		public function set UpdateFrequency(newfreq:Number):void
		{
			if (newfreq < StringConstants.MINIMUM_FREQUENCY)
			{
				newfreq = StringConstants.MINIMUM_FREQUENCY;
			}
				var baFreq:ByteArray = new ByteArray();
				baFreq.writeInt(newfreq);
				EncryptedLocalStore.setItem(StringConstants.ELS_UPDATE_FREQUENCY,baFreq);
				updatemodel.instance._updatetimer.delay = newfreq * 1000;
		}
		
		public function set StartOnLogon(newval:Boolean):void
		{
			try
			{
				var currVal:Boolean = NativeApplication.nativeApplication.startAtLogin;
				_startup = newval;
				if (currVal != newval)
				{
					NativeApplication.nativeApplication.startAtLogin = newval;
					var baStartup:ByteArray = new ByteArray();
					baStartup.writeBoolean(newval);
					EncryptedLocalStore.setItem(StringConstants.ELS_START_ON_LOGON,baStartup);
				}
			}
			catch (e:Error)
			{
				Logger.instance.log("Cannot use Start On Logon at this time. Only usable when the app is installed, not in ADL runtime.",Logger.SEVERITY_NORMAL);
			}
		}
		
		private function LoadOptions():void
		{
		}
		
		
		public function get ShowInTaskBar():Boolean
		{
			
			var baShowInTaskBar:ByteArray = EncryptedLocalStore.getItem(StringConstants.ELS_SHOW_IN_TASKBAR);
			if (baShowInTaskBar != null)
				_showintaskbar = baShowInTaskBar.readBoolean();
			return _showintaskbar;
		}
		public function set ShowInTaskBar(newval:Boolean):void
		{
			var baShowInTaskbar:ByteArray = new ByteArray();
			baShowInTaskbar.writeBoolean(newval);
			EncryptedLocalStore.setItem(StringConstants.ELS_SHOW_IN_TASKBAR,baShowInTaskbar);
			_showintaskbar = newval;
			dispatchEvent(new OptionsEvent(OptionsEvent.OPTIONS_SHOW_IN_TASKBAR_CHANGED));
		}
		
		public function get AlwaysOnTop():Boolean
		{
			var baAlwaysOnTop:ByteArray = EncryptedLocalStore.getItem(StringConstants.ELS_ALWAYS_ON_TOP);
			if (baAlwaysOnTop != null)
			{
				_alwaysontop = baAlwaysOnTop.readBoolean();
				Logger.instance.log("Initializing Always On Logon to " + _alwaysontop + " from ELS.",Logger.SEVERITY_NORMAL);
			}
			else
			{
				Logger.instance.log("Initializing Always on top to " + _alwaysontop + " by default.");
			}
			return _alwaysontop;
		}
		public function set AlwaysOnTop(newval:Boolean):void
		{
			_alwaysontop = newval;
			var baAlwaysOnTop:ByteArray = new ByteArray();
			baAlwaysOnTop.writeBoolean(newval);
			EncryptedLocalStore.setItem(StringConstants.ELS_ALWAYS_ON_TOP,baAlwaysOnTop);
			dispatchEvent(new OptionsEvent(OptionsEvent.OPTIONS_ALWAYS_ON_TOP_CHANGED));
		}
		
		public function set AutoShow(newval:Boolean):void
		{
			if (newval != _autoShow)
			{
				var baAutoShow:ByteArray = new ByteArray();
				baAutoShow.writeBoolean(newval);
				EncryptedLocalStore.setItem(StringConstants.ELS_AUTO_SHOW,baAutoShow);
			}
			_autoShow = newval;
			dispatchEvent(new OptionsEvent(OptionsEvent.OPTIONS_AUTOSHOW_CHANGED));
		}
		public function get AutoShow():Boolean
		{
			var baAutoShow:ByteArray = EncryptedLocalStore.getItem(StringConstants.ELS_AUTO_SHOW);
			if (baAutoShow != null)
			{
				_autoShow = baAutoShow.readBoolean();
			}
			return _autoShow;
		}
		
		public static function get instance():OptionsModel
		{
			return _instance;
		}
		
		public function OptionsModel(target:IEventDispatcher=null)
		{
			super(target);
			LoadOptions();
			Logger.instance.log("Options constructed",Logger.SEVERITY_SERIOUS);
		}
		
		public function get SiteURL():String
		{
			var basiteurl:ByteArray = EncryptedLocalStore.getItem(StringConstants.ELS_SITEURL);
			if (basiteurl != null) return basiteurl.readUTFBytes(basiteurl.bytesAvailable); else return "";
		}
		public function get Username():String
		{
			var bausername:ByteArray = EncryptedLocalStore.getItem(StringConstants.ELS_USERNAME);
			if (bausername != null) return bausername.readUTFBytes(bausername.bytesAvailable); else return "";
		}
		public function get Password():String
		{
			var bapassword:ByteArray = EncryptedLocalStore.getItem(StringConstants.ELS_PASSWORD);
			if (bapassword != null ) return bapassword.readUTFBytes(bapassword.bytesAvailable); else return "";
		}

		
		public function get SaveCynInID():Boolean
		{
			var baSaveID:ByteArray = EncryptedLocalStore.getItem(StringConstants.ELS_SAVE_CYNIN_ID);
			if (baSaveID != null ) return baSaveID.readBoolean(); else return StringConstants.DEFAULT_SAVE_ID;
		}
		public function set SaveCynInID(newval:Boolean):void
		{
			if (newval == false)
			{
				UnStoreIDDetails();
				dispatchEvent(new OptionsEvent(OptionsEvent.OPTIONS_SAVECYNINID_CHANGED));
				UnStorePassword();
				dispatchEvent(new OptionsEvent(OptionsEvent.OPTIONS_SAVEPASSWORD_CHANGED));
			}
			else
			{
				StoreIDDetails();
			}
		}
		public function get SavePassword():Boolean
		{
			var baSavePass:ByteArray = EncryptedLocalStore.getItem(StringConstants.ELS_SAVE_PASSWORD);
			if (baSavePass != null) return baSavePass.readBoolean(); else return StringConstants.DEFAULT_SAVE_PASSWORD;
		}
		public function set SavePassword(newval:Boolean):void
		{
			if (newval == false)
			{
				UnStorePassword();
				dispatchEvent(new OptionsEvent(OptionsEvent.OPTIONS_SAVEPASSWORD_CHANGED));
			}
			else
			{
				StorePassword();
				dispatchEvent(new OptionsEvent(OptionsEvent.OPTIONS_SAVEPASSWORD_CHANGED));
			}
		}
		
		public function StoreIDDetails():void
		{
			var baSaveID:ByteArray = new ByteArray();
			baSaveID.writeBoolean(true);
			EncryptedLocalStore.setItem(StringConstants.ELS_SAVE_CYNIN_ID,baSaveID);

			var basiteurl:ByteArray = new ByteArray();
			basiteurl.writeUTFBytes(updatemodel.instance.SiteURL);
			EncryptedLocalStore.setItem(StringConstants.ELS_SITEURL,basiteurl);
			
			var bausername:ByteArray = new ByteArray();
			bausername.writeUTFBytes(updatemodel.instance.username);
			EncryptedLocalStore.setItem(StringConstants.ELS_USERNAME,bausername);
		}
		
		public function StorePassword():void
		{
			var baSavePassword:ByteArray = new ByteArray();
			baSavePassword.writeBoolean(true);
			EncryptedLocalStore.setItem(StringConstants.ELS_SAVE_PASSWORD,baSavePassword);

			var bapassword:ByteArray = new ByteArray();
			bapassword.writeUTFBytes(updatemodel.instance.password);
			EncryptedLocalStore.setItem(StringConstants.ELS_PASSWORD,bapassword);
		}
		public function UnStoreIDDetails():void
		{
			var baSaveID:ByteArray = new ByteArray();
			baSaveID.writeBoolean(false);
			EncryptedLocalStore.setItem(StringConstants.ELS_SAVE_CYNIN_ID,baSaveID);

			var baSavePassword:ByteArray = new ByteArray();
			baSavePassword.writeBoolean(false);
			EncryptedLocalStore.setItem(StringConstants.ELS_SAVE_PASSWORD,baSavePassword);

			EncryptedLocalStore.removeItem(StringConstants.ELS_PASSWORD);
			EncryptedLocalStore.removeItem(StringConstants.ELS_USERNAME);
			EncryptedLocalStore.removeItem(StringConstants.ELS_PASSWORD);
		}
		public function UnStorePassword():void
		{
			var baSavePassword:ByteArray = new ByteArray();
			baSavePassword.writeBoolean(false);
			EncryptedLocalStore.setItem(StringConstants.ELS_SAVE_PASSWORD,baSavePassword);

			EncryptedLocalStore.removeItem(StringConstants.ELS_PASSWORD);
		}
	}
}