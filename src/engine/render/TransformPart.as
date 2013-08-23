/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.render
{
	import flash.geom.Matrix3D;

	public class TransformPart
	{
		[Required]
		public var transform:Transform;
		
		public var worldMatrix:Matrix3D;
		
		public var prev:TransformPart;
		public var next:TransformPart;

		public static const required:Object = {
			transform:Transform
		};
	}
}
