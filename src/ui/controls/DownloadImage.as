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
package ui.controls
{
	import code.google.as3httpclient.SocketURLLoader;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.utils.ByteArray;
	
	import model.logger.Logger;
	import model.updates.DownloadEvent;
	import model.updates.RegularEvent;
	import model.updates.updatemodel;
	
	import mx.collections.ArrayCollection;
	import mx.utils.Base64Encoder;
	
	public class DownloadImage extends EventDispatcher
	{
        private var encoder:Base64Encoder = new Base64Encoder();
		private var acFiles:ArrayCollection = new ArrayCollection();
		
		public function DownloadImage(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function get QueueLength():int
		{
			return acFiles.length;
		}
		
		public function SaveToFile(url:String, savepath:File,objectToPassToCallback:Object,type:String):void
		{
			var socketLoader:SocketURLLoader = new SocketURLLoader();
            socketLoader.dataFormat = URLLoaderDataFormat.BINARY;
            socketLoader.addEventListener("complete", completeHandler);
            socketLoader.addEventListener("ioError", ioErrorHandler);
            socketLoader.addEventListener("open", openHandler);
            socketLoader.addEventListener("progress", progressHandler);
            socketLoader.addEventListener("securityError", securityErrorHandler);
			var downloadobj:Object = new Object();
			var shttp:URLRequest = new URLRequest(url);
			encoder.encode(updatemodel.instance.username + ":" + updatemodel.instance.password);
			var reqh:URLRequestHeader = new URLRequestHeader("Authorization","Basic " + encoder.toString());
			shttp.requestHeaders.push(reqh);
			downloadobj.url = url;
			downloadobj.savepath = savepath;
			downloadobj.sockobj = socketLoader;
			downloadobj.passobj = objectToPassToCallback;
			downloadobj.type = type;
			acFiles.addItem(downloadobj);
			socketLoader.load(shttp);
		}
		
        private function completeHandler(event:Event):void 
        {
        	//this.currentState = "";
            Logger.instance.log("SocketDownload Complete: " + event.currentTarget.toString(),Logger.SEVERITY_NORMAL);
            var socketLoader:SocketURLLoader = event.currentTarget as SocketURLLoader;
            var obj:Object = getDownloadObject(socketLoader);
            if (obj != null)
            {
	 	        var writeFile:File = obj.savepath;
	 	        var fileStream:FileStream = null;
	 	        try
	 	        {
	 	        	fileStream= new FileStream();
					fileStream.open(writeFile, FileMode.WRITE);
					var ba:ByteArray = SocketURLLoader(event.target).data as ByteArray;
					fileStream.writeBytes(ba );
					fileStream.close();
					acFiles.removeItemAt(acFiles.getItemIndex(obj));
					if (acFiles.length == 0) updatemodel.instance.dispatchEvent(new RegularEvent(RegularEvent.IMAGE_DOWNLOAD_QUEUE_EMPTY));
					dispatchEvent(new DownloadEvent(obj.type,obj.url,writeFile,obj.passobj));
	 	        }
	 	        catch(error:Error)
	 	        {
					Logger.instance.log("Serious error writing to file: " + writeFile.nativePath + ", " + error.message,Logger.SEVERITY_SERIOUS); 		        	
	 	        }
            }
            else
            {
            	Logger.instance.log("getDownloadObject return null, SERIOUS download issue.",Logger.SEVERITY_SERIOUS);
            }
        }

		private function getDownloadObject(socketLoader:SocketURLLoader):Object
		{
			for each (var obj:Object in acFiles)
			{
				if (obj.sockobj == socketLoader)
					return obj;
			}
			return null;
		}
        private function ioErrorHandler(event:IOErrorEvent):void 
        {
            Logger.instance.log("IOError when downloading:" + event.currentTarget.toString(),Logger.SEVERITY_NORMAL);
        }


        private function progressHandler(event:ProgressEvent):void 
        {
        	
            //trace("progressHandler: bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
        }
        private function openHandler(event:Event):void 
        {
            Logger.instance.log("Opened:" + event.currentTarget.toString(),Logger.SEVERITY_NORMAL);
        }

        private function securityErrorHandler(event:SecurityErrorEvent):void 
        {
            Logger.instance.log("SecurityErrorEvent when downloading:" + event.currentTarget.toString(),Logger.SEVERITY_NORMAL);
        }
		

	}
}