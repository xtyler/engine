/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.core
{
	public class Entity
	{
		public var name:String;

		public var engine:Engine;
		public var prev:Entity;
		public var next:Entity;
		public var last:Entity;

		public var firstComponent:Component;
		public var lastComponent:Component;

		public function Entity(name:String = null) {
			this.name = name;
			last = this;
		}

		public function hasComponent(component:Component):Boolean {
			return component && component.entity == this;
		}

		public function getComponent(type:Class):* {
			var component:Component = firstComponent;
			while (component) {
				if (component is type) {
					return component;
				}
				component = component.next;
			}
			return null;
		}

		public function getComponents(type:Class):* {
			var components:Array = [];
			var component:Component = firstComponent;
			while (component) {
				if (component is type) {
					components.push(component);
				}
				component = component.next;
			}
			return components;
		}

		public function getComponentsInChildren(type:Class):* {
			var components:Array = [];
			var child:Entity = next;
			while (child != last.next) {
				var component:Component = firstComponent;
				while (component) {
					if (component is type) {
						components.push(component);
					}
					component = component.next;
				}
				child = child.next;
			}
			return components;
		}

		public function addComponent(component:Component, before:Component = null):* {
			if (!component || (component.entity == this && component.next == before)) {
				return component;
			} else if (component.entity) {
				component.entity.removeComponent(component);
			}

			if (before && before.entity == this) {
				if (before.prev) {
					before.prev.next = component;
					component.prev = before.prev;
				} else {
					firstComponent = component;
				}
				component.next = before;
				before.prev = component;
			} else {
				if (lastComponent) {
					lastComponent.next = component;
					component.prev = lastComponent;
				} else {
					firstComponent = component;
				}
				lastComponent = component;
			}
			component.entity = this;

			if (engine) {
				engine.entityChanged(this, component);
			}

			return component;
		}

		public function removeComponent(component:Component):* {
			if (!component || component.entity != this) {
				return component;
			}

			if (component.prev) {
				component.prev.next = component.next;
			} else {
				firstComponent = component.next;
			}

			if (component.next) {
				component.next.prev = component.prev;
			} else {
				lastComponent = component.prev;
			}

			component.prev = null;
			component.next = null;
			component.entity = null;

			if (engine) {
				engine.entityChanged(this, component);
			}

			return component;
		}
	}
}
