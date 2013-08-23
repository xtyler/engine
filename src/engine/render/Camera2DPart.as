/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.render
{
	public class Camera2DPart
	{
		[Required]
		public var camera2D:Camera2D;
		
		[Required]
		public var transform:Transform;
		
		public var prev:Camera2DPart;
		public var next:Camera2DPart;
		
		public static const required:Object = {
			camera2D:Camera2D,
			transform:Transform
		};
	}
}
