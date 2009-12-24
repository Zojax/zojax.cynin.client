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
package ui.tiles
{
	import flash.display.GradientType;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	import model.updates.BaseItem;
	
	import mx.containers.Canvas;
	import mx.events.FlexEvent;

	public class BaseTile extends Canvas
	{
		private var _isRolledOver:Boolean = false;
		public var _bgInvalid:Boolean = false;
		public var isSelected:Boolean = false;
		public var HasLoaded:Boolean = false;
		[Bindable] public var Item:BaseItem = null;
		
		//Fill Colors
		protected var gradBaseFrom:Number = 0;
		protected var gradBaseTo:Number = 0;
		protected var gradHoverFrom:Number = 0xCCCCCC;
		protected var gradHoverTo:Number = 0x555555;
		protected var gradSelectedFrom:Number = 0x71B9F7;
		protected var gradSelectedTo:Number = 0x0F6BBA;
		protected var gradSelectedHoveredFrom:Number = 0x0F6BBA;
		protected var gradSelectedHoveredTo:Number = 0x71B9F7;
		
		//Fill Alphas
		protected var fillBaseFrom:Number = 0;
		protected var fillBaseTo:Number = 0;
		protected var fillHoverFrom:Number = 0.5;
		protected var fillHoverTo:Number = 0.5;
		protected var fillSelectedFrom:Number = 1;
		protected var fillSelectedTo:Number = 1;
		protected var fillSelectedHoveredFrom:Number = 1;
		protected var fillSelectedHoveredTo:Number = 1;
			
			
		public function BaseTile()
		{
			addEventListener(FlexEvent.CREATION_COMPLETE, inited);
			super();
		}
		private function inited(event:Event):void
		{
			addEventListener(MouseEvent.MOUSE_OVER, handleRollOver);
			addEventListener(MouseEvent.MOUSE_OUT, handleRollOut);
			_bgInvalid = true;
			invalidateDisplayList();
		}
		private function handleRollOver(event: Event): void {
			_isRolledOver = true;
			_bgInvalid = true;
			invalidateDisplayList();
		}
		
		private function handleRollOut(event: Event): void {
			_isRolledOver = false;
			_bgInvalid = true;
			invalidateDisplayList();
		}
		
		public function dispose():void
		{
			removeEventListener(MouseEvent.MOUSE_OVER, handleRollOver);
			removeEventListener(MouseEvent.MOUSE_OUT, handleRollOut);
			removeEventListener(FlexEvent.CREATION_COMPLETE, inited);
		}
		
		override protected function updateDisplayList(unscaledWidth: Number, unscaledHeight: Number): void 
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (_bgInvalid) {
				graphics.clear();

				var gradientMatrix:Matrix = new Matrix();
				if (_isRolledOver && isSelected)
				{
					gradientMatrix.createGradientBox(unscaledWidth, unscaledHeight, Math.PI / 2, 0, 0);
					graphics.beginGradientFill(GradientType.LINEAR, [gradSelectedHoveredFrom, gradSelectedHoveredTo], [fillSelectedHoveredFrom, fillSelectedHoveredTo], [0, 255], gradientMatrix);
					graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
					graphics.endFill();
				}
				else if (isSelected)
				{
					gradientMatrix.createGradientBox(unscaledWidth, unscaledHeight, Math.PI / 2, 0, 0);
					graphics.beginGradientFill(GradientType.LINEAR, [gradSelectedFrom, gradSelectedTo], [fillSelectedFrom, fillSelectedTo], [0, 255], gradientMatrix);
					graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
					graphics.endFill();
				}
				else if (_isRolledOver) 
				{
					gradientMatrix.createGradientBox(unscaledWidth, unscaledHeight, Math.PI / 2, 0, 0);
					graphics.beginGradientFill(GradientType.LINEAR, [gradHoverFrom, gradHoverTo], [fillHoverFrom, fillHoverTo], [0, 255], gradientMatrix);
					graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
					graphics.endFill();
				}
				else 
				{
					gradientMatrix.createGradientBox(unscaledWidth, unscaledHeight, Math.PI / 2, 0, 0);
					graphics.beginGradientFill(GradientType.LINEAR, [gradBaseFrom, gradBaseTo], [fillBaseFrom, fillBaseTo], [0, 255], gradientMatrix);
					graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
					graphics.endFill();
				}
				_bgInvalid = false;				
			}
		}
	}
}