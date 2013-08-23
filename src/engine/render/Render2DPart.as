/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.render
{
	public class Render2DPart
	{
		[Required]
		public var meshRenderer:MeshRenderer;
		
		[Required]
		public var transform:Transform;

		public var prev:Render2DPart;
		public var next:Render2DPart;

		public static const required:Object = {
			transform:Transform,
			meshRenderer:MeshRenderer
		};
	}
}
