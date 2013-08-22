/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.ui
{
	public class UI
	{
		public var data:Object;
		public var dataType:Class;
		
		public var skin:UI;
		
		// (for the child of CONTENT)
		// getter to this.parent.contentOwner (usually itself)
		public var parent:UI;

		// (for the COMPONENT)
		// getter(/setter) to first skin.content.* or this.*
		public var numChildren:uint;
		public var firstChild:UI;
		public var lastChild:UI;
		//public var layout:LayoutAlgorithm;

		// (same) getter to this.*
		public var previousSibling:UI;
		public var nextSibling:UI;

		
		public function UI() {
		}

		public function containsChild(child:UI):Boolean {
			return false;
		}

		public function addChild(child:UI, before:UI = null):UI {
			return child;
		}

		public function removeChild(child:UI):UI {
			return child;
		}

		public function removeChildren():void {
		}
	}
}
