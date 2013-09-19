/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.core
{
	import engine.render.Transform;

	public class TestEntity
	{
		public static var tests:Array = [
			"entityInitialComponentTests",
			"entityComponentManagementTests"
		];

		public function TestEntity() {
		}

		public function entityComponentManagementTests():void {
			var entity1:Entity = new Entity();
			var entity2:Entity = new Entity();
			var component1:MockComponent1 = new MockComponent1();
			var component2:MockComponent2 = new MockComponent2();

			// component can be added and should be at the end
			entity1.addComponent(component1);
			Testing.assertTrue(entity1.hasComponent(component1));
			Testing.assertEquals(entity1.getComponent(MockComponent1), component1);
			Testing.assertEquals(entity1.getComponents(MockComponent1).pop(), component1);
			Testing.assertEquals(component1.nextComponent, null);
			Testing.assertEquals(entity1.lastComponent, component1);

			// component can be added before another
			entity1.addComponent(component2, component1);
			Testing.assertTrue(entity1.hasComponent(component2));
			Testing.assertEquals(entity1.getComponent(MockComponent2), component2);
			Testing.assertEquals(entity1.getComponents(MockComponent2).pop(), component2);
			Testing.assertEquals(component2.nextComponent, component1);
			Testing.assertEquals(entity1.lastComponent, component1);

			// components should not be found in children
			Testing.assertEquals(entity1.getComponentInChildren(MockComponent1), null);
			Testing.assertEquals(entity1.getComponentsInChildren(MockComponent1).length, 0);

			// components can not be added twice
			entity1.addComponent(component1);
			Testing.assertEquals(entity1.getComponents(MockComponent1).length, 1);

			// component can be removed
			entity1.removeComponent(component1);
			Testing.assertFalse(entity1.hasComponent(component1));
			Testing.assertEquals(entity1.getComponent(MockComponent1), null);
			Testing.assertEquals(entity1.getComponents(MockComponent1).length, 0);
			Testing.assertEquals(component2.nextComponent, null);
			Testing.assertEquals(entity1.lastComponent, component2);
			Testing.assertEquals(component1.nextComponent, null);
			Testing.assertEquals(component1.prevComponent, null);

			// component added to another entity should be removed from the first
			entity2.addComponent(component2);
			Testing.assertFalse(entity1.hasComponent(component2));
			Testing.assertEquals(entity1.getComponent(MockComponent2), null);
			Testing.assertEquals(entity1.getComponents(MockComponent2).length, 0);
			Testing.assertTrue(entity2.hasComponent(component2));
			Testing.assertEquals(entity2.getComponent(MockComponent2), component2);
			Testing.assertEquals(entity2.getComponents(MockComponent2).length, 1);

			Testing.run();
		}

		public function entityInitialComponentTests():void {
			var entity:Entity = new Entity();

			// first and only component "out of the box" is a Transform
			Testing.assertTrue(entity.firstComponent is Transform);
			Testing.assertEquals(entity.firstComponent, entity.lastComponent);
			Testing.assertTrue(entity.hasComponent(entity.firstComponent));
			Testing.assertTrue(entity.getComponent(Transform) is Transform);
			Testing.assertEquals(entity.getComponents(Object).length, 1);
			Testing.assertTrue(entity.getComponents(Transform).pop() is Transform);

			// components are found by type and can be looked up by superclass
			Testing.assertTrue(entity.getComponent(Component) is Transform);

			Testing.run();
		}
	}
}
