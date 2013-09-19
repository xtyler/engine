/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.display
{
	import engine.core.Component;

	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Shader;
	import flash.geom.ColorTransform;

	public class Display extends Component
	{
		public var background:Object;
		public var tint:ColorTransform;
		public var alpha:Number = 1;
		public var mask:Display;
		public var maskType:String;

		public var blendMode:String = BlendMode.NORMAL;
		public var blendShader:Shader;
		public var filtersEnabled:Boolean = true;
		public var filters:Array;

		public var target:DisplayObject;

		// TODO: store state changes for DisplaySystem to apply

		public function Display() {
		}

	}
}
