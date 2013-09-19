/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.render
{
	import engine.core.Component;
	import engine.core.Entity;

	import flash.geom.Vector3D;

	public class Transform extends Component
	{
		static public const defaultPosition:Vector3D = new Vector3D(0, 0, 0);
		static public const defaultRotation:Vector3D = new Vector3D(0, 0, 0);
		static public const defaultScale:Vector3D = new Vector3D(1, 1, 1);

		public function get position():Vector3D {
			return _position != defaultPosition ? _position : (_position = defaultPosition.clone());
		}
		internal var _position:Vector3D = defaultPosition;

		public function get rotation():Vector3D {
			return _rotation != defaultRotation ? _rotation : (_rotation = defaultRotation.clone());
		}
		internal var _rotation:Vector3D = defaultRotation;

		public function get scale():Vector3D {
			return _scale != defaultScale ? _scale : (_scale = defaultScale.clone());
		}
		internal var _scale:Vector3D = defaultScale;

		public var parent:Transform;
		public var numChildren:uint;
		public var firstChild:Transform;
		public var lastChild:Transform;
		public var previousSibling:Transform;
		public var nextSibling:Transform;

		public var space:Transform;
		public var background:Transform;
		public var content:Transform;

		public function Transform() {
		}

		public function setBackground(background:Transform, content:Transform = null):void {
			// remove current background
			if (this.background) {

				var lastEntity:Entity;
				if (firstChild) {



					// remove children from background
					if (this.content) {
						this.content.entity.nextEntity = this.content.entity.lastEntity.nextEntity;

						this.content.entity.lastEntity = this.content.entity;
					} else {
						this.content.entity.nextEntity = this.content.entity.lastEntity.nextEntity;
						this.content.entity.lastEntity = this.content.entity;
					}

					this.background.entity.prevEntity = null;
					this.background.entity.lastEntity.nextEntity = null;


					firstChild.entity.prevEntity = entity;
					entity.nextEntity = firstChild.entity;

					lastEntity = lastChild.entity.lastEntity;
					lastEntity.nextEntity = entity.lastEntity.nextEntity;
					entity.lastEntity.nextEntity.prevEntity = lastEntity;

					var child:Transform = firstChild;
					while (child) {
						child.space = this;
						child = child.nextSibling;
					}
				} else {
					lastEntity = entity;
				}

				var ancestor:Transform = space;
				while (ancestor &&
						ancestor.entity.lastEntity == entity.lastEntity) {
					ancestor.entity.lastEntity = lastEntity;
					ancestor = ancestor.space;
				}
				entity.lastEntity = lastEntity;

			}
//			// support for backgrounds, background content and background content default children
//			if (background) {
//				if (content) {
//					// remove any content default children
//					if (content.firstChild) {
//						content.removeAll();
//					}
//					if (prevEntity == entity) {
//						prevEntity = content.entity;
//					}
//					child.space = content;
//				} else {
//					// without a content area, treat background as a background
//					if (prevEntity == entity) {
//						prevEntity = background.entity.lastEntity;
//					}
//					child.space = Transform(background.entity.lastEntity);
//				}
//			}

			this.background = background;
		}

		public function has(child:Transform):Boolean {
			return child && child.parent == this;
		}

		public function add(child:Transform, before:Transform = null):Transform {
			if (!child || (child.parent == this && child.nextSibling == before)) {
				return child;
			} else if (child.parent) {
				child.parent.remove(child);
			}

			var prevEntity:Entity;
			var nextEntity:Entity;

			if (before && before.parent == this) {
				if (before.previousSibling) {
					before.previousSibling.nextSibling = child;
					child.previousSibling = before.previousSibling;
					prevEntity = child.previousSibling.entity.lastEntity;
				} else {
					firstChild = child;
					prevEntity = entity;
				}
				child.nextSibling = before;
				before.previousSibling = child;
			} else {
				if (lastChild) {
					lastChild.nextSibling = child;
					child.previousSibling = lastChild;
					prevEntity = lastChild.entity.lastEntity;
				} else {
					firstChild = child;
					prevEntity = entity;
				}
				lastChild = child;
			}
			child.parent = this;
			numChildren++;

			child.space = this;

			if (prevEntity) {
				// support for backgrounds, background content and background content default children
				if (background) {
					if (content) {
						// remove any content default children
						if (content.firstChild) {
							content.removeAll();
						}
						if (prevEntity == entity) {
							prevEntity = content.entity;
						}
						child.space = content;
					} else {
						// without a content area, treat background as a background
						if (prevEntity == entity) {
							prevEntity = background.entity.lastEntity;
						}
						child.space = Transform(background.entity.lastEntity);
					}
				}

				nextEntity = prevEntity.nextEntity;
				prevEntity.nextEntity = child.entity;
				child.entity.prevEntity = prevEntity;
			}
			if (nextEntity) {
				nextEntity.prevEntity = child.entity.lastEntity;
				child.entity.lastEntity.nextEntity = nextEntity;
			}

			var ancestor:Transform = child.space;
			while (ancestor &&
					ancestor.entity.lastEntity == child.space.entity.lastEntity) {
				ancestor.entity.lastEntity = child.entity.lastEntity;
				ancestor = ancestor.space;
			}

			if (entity.engine) {
				entity.engine.entityAdded(child.entity);
			}

			return child;
		}

		public function remove(child:Transform):Transform {
			if (!child || child.parent != this) {
				return child;
			}

			if (entity.engine) {
				entity.engine.entityRemoved(child.entity);
			}

			if (child.previousSibling) {
				child.previousSibling.nextSibling = child.nextSibling;
			} else {
				firstChild = child.nextSibling;
			}

			if (child.nextSibling) {
				child.nextSibling.previousSibling = child.previousSibling;
			} else {
				lastChild = child.previousSibling;
			}
			child.previousSibling = null;
			child.nextSibling = null;
			child.parent = null;
			numChildren--;

			var ancestor:Transform = child.space;
			while (ancestor &&
					ancestor.entity.lastEntity == child.entity.lastEntity) {
				ancestor.entity.lastEntity = child.entity.prevEntity;
				ancestor = ancestor.space;
			}

			if (child.entity.prevEntity) {
				child.entity.prevEntity.nextEntity = child.entity.lastEntity.nextEntity;
				child.entity.prevEntity = null;
			}
			if (child.entity.lastEntity.nextEntity) {
				child.entity.lastEntity.nextEntity.prevEntity = child.entity.prevEntity;
				child.entity.lastEntity.nextEntity = null;
			}
			child.space = null;

			return child;
		}

		public function removeAll():void {
			var child:Transform = firstChild;
			while (child) {
				if (entity.engine) {
					entity.engine.entityRemoved(child.entity);
				}
				child = child.nextSibling;
			}

			if (firstChild) {
				var ancestor:Transform = this;
				while (ancestor &&
						ancestor.entity.lastEntity == lastChild.entity.lastEntity) {
					ancestor.entity.lastEntity = firstChild.entity.prevEntity;
					ancestor = ancestor.space;
				}
			}

			child = firstChild;
			while (child) {
				var nextSibling:Transform = child.nextSibling;
				child.previousSibling = null;
				child.nextSibling = null;
				child.parent = null;

				if (child.entity.prevEntity) {
					child.entity.prevEntity.nextEntity = child.entity.lastEntity.nextEntity;
					child.entity.prevEntity = null;
				}
				if (child.entity.lastEntity.nextEntity) {
					child.entity.lastEntity.nextEntity.prevEntity = child.entity.prevEntity;
					child.entity.lastEntity.nextEntity = null;
				}
				child.space = null;

				child = nextSibling;
			}

			firstChild = null;
			lastChild = null;
			numChildren = 0;
		}
	}
}
