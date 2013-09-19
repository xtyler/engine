/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.core
{
	public class Entity
	{
		public var name:String;

		public var engine:Engine;
		public var prevEntity:Entity;
		public var nextEntity:Entity;
		public var lastEntity:Entity;

		public var firstComponent:Component;
		public var lastComponent:Component;

		public function Entity(name:String = null) {
			this.name = name;
			lastEntity = this;
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
				component = component.nextComponent;
			}
			return null;
		}

		public function getComponents(type:Class):Array {
			var components:Array = [];
			var component:Component = firstComponent;
			while (component) {
				if (component is type) {
					components.push(component);
				}
				component = component.nextComponent;
			}
			return components;
		}

		public function getComponentInChildren(type:Class):* {
			var child:Entity = nextEntity;
			while (child != lastEntity.nextEntity) {
				var component:Component = firstComponent;
				while (component) {
					if (component is type) {
						return component;
					}
					component = component.nextComponent;
				}
				child = child.nextEntity;
			}
			return null;
		}

		public function getComponentsInChildren(type:Class):Array {
			var components:Array = [];
			var child:Entity = nextEntity;
			while (child != lastEntity.nextEntity) {
				var component:Component = firstComponent;
				while (component) {
					if (component is type) {
						components.push(component);
					}
					component = component.nextComponent;
				}
				child = child.nextEntity;
			}
			return components;
		}

		public function addComponent(component:Component, before:Component = null):* {
			if (!component || (component.entity == this && component.nextComponent == before)) {
				return component;
			} else if (component.entity) {
				component.entity.removeComponent(component);
			}

			if (before && before.entity == this) {
				if (before.prevComponent) {
					before.prevComponent.nextComponent = component;
					component.prevComponent = before.prevComponent;
				} else {
					firstComponent = component;
				}
				component.nextComponent = before;
				before.prevComponent = component;
			} else {
				if (lastComponent) {
					lastComponent.nextComponent = component;
					component.prevComponent = lastComponent;
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

			if (component.prevComponent) {
				component.prevComponent.nextComponent = component.nextComponent;
			} else {
				firstComponent = component.nextComponent;
			}

			if (component.nextComponent) {
				component.nextComponent.prevComponent = component.prevComponent;
			} else {
				lastComponent = component.prevComponent;
			}

			component.prevComponent = null;
			component.nextComponent = null;
			component.entity = null;

			if (engine) {
				engine.entityChanged(this, component);
			}

			return component;
		}
	}
}
