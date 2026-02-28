using System;
using cpp17_optionalNamespace;

public class runme
{
	static void Main()
	{
		var testOptionals = new TestOptionals();

		// Checking SimpleOptional
		{
			var optU32 = testOptionals.getSimpleOptional();
			if (optU32 != null || optU32 is uint)
				throw new Exception("TestOptionals.getSimpleOptional() failed");
			testOptionals.setSimpleOptional(42u);
			optU32 = testOptionals.getSimpleOptional();
			if (optU32 == null || !(optU32 is uint))
				throw new Exception("TestOptionals.setSimpleOptional() failed");
			testOptionals.setSimpleOptional(null);
			optU32 = testOptionals.getSimpleOptional();
			if (optU32 != null || optU32 is uint)
				throw new Exception("TestOptionals.setSimpleOptional() failed");
		}

		// Checking StringOptional
		{
			var optStr = testOptionals.getStringOptional();
			if (optStr != null || optStr is string)
				throw new Exception("TestOptionals.getStringOptional() failed");
			testOptionals.setStringOptional("Hello, World!");
			optStr = testOptionals.getStringOptional();
			if (optStr == null || !(optStr is string))
				throw new Exception("TestOptionals.setStringOptional() failed");
			testOptionals.setStringOptional(null);
			optStr = testOptionals.getStringOptional();
			if (optStr != null || optStr is string)
				throw new Exception("TestOptionals.setStringOptional() failed");
		}

		// Checking CustomOptional
		{
			// Empty StructOptional
			{
				var optStruct = testOptionals.getStructOptional();
				if (optStruct != null)
					throw new Exception("TestOptionals.getStructOptional() failed");
			}
			// setStructOptional()
			{
				var structObj = new Struct { a = 56u, b = 78u, sub = new SubStruct { z = 99u } };
				testOptionals.setStructOptional(structObj);
				var optStruct = testOptionals.getStructOptional();
				if (optStruct == null)
					throw new Exception("TestOptionals.setStructOptional() failed");
				if (optStruct?.a != 56u || optStruct?.b != 78u || optStruct?.sub.z != 99u)
					throw new Exception("TestOptionals.setStructOptional() failed");
				var optStructCopy = testOptionals.getStructOptionalCopy();
				if (optStructCopy == null)
					throw new Exception("TestOptionals.setStructOptional() failed");
				if (optStructCopy?.a != 56u || optStructCopy?.b != 78u || optStructCopy?.sub.z != 99u)
					throw new Exception("TestOptionals.setStructOptional() failed");
				// Test struct modifier
				structObj.a = 4u;
				structObj.b = 2u;
				structObj.sub.z = 1u;
				testOptionals.setStructOptional(structObj);
				if (optStruct?.a != 4u || optStruct?.b != 2u || optStruct?.sub?.z != 1u)
					throw new Exception("TestOptionals.setStructOptional() failed");
				if (optStructCopy?.a != 56u || optStructCopy?.b != 78u || optStructCopy?.sub?.z != 99u)
					throw new Exception("TestOptionals.setStructOptional() failed");

				// Clear the optional
				testOptionals.setStructOptional(null);
				optStruct = testOptionals.getStructOptional();
				if (optStruct != null)
					throw new Exception("TestOptionals.setStructOptional() failed");
			}
		}

		// Checking TestObjectString
		{
			// getName()
			{
				// Initialize the object with a string value
				var obj = new TestObjectString("InitialName");
				// Test getName method
				if (obj.getName() != "InitialName")
					throw new Exception("TestObjectString.getName() failed");
			}
			// setName()
			{
				// Initialize with a different string value
				var obj = new TestObjectString("AnotherName");
				// Set a new name and verify the getName method
				obj.setName("NewName");
				if (obj.getName() != "NewName")
					throw new Exception("TestObjectString.setName() failed");
			}
			// getName()/setName() with optional string
			{
				// Initialize with a string value
				var obj = new TestObjectString("OptionalTest");
				// Set and get an optional string
				obj.setNameOpt("OptionalName");
				if (obj.getNameOpt() != "OptionalName")
					throw new Exception("TestObjectString.getNameOpt() failed");
				// Clear the optional string by setting it to null
				obj.setNameOpt(null);
				// Verify that the optional string is empty
				if (obj.getNameOpt() != null)
					throw new Exception("TestObjectString.getNameOpt() failed");
			}
			// getName()/setName() with optional empty string
			{
				// Initialize with a string value
				var obj = new TestObjectString("OptionalTest");
				// Set and get an optional empty string
				obj.setNameOpt("");
				if (obj.getNameOpt() != "")
					throw new Exception("TestObjectString.getNameOpt() failed");
				// Clear the optional string by setting it to null
				obj.setNameOpt(null);
				// Verify that the optional string is empty
				if (obj.getNameOpt() != null)
					throw new Exception("TestObjectString.getNameOpt() failed");
			}
		}

		// Checking TestObjectPrimitives
		{
			// get/set with primitive types
			{
				// Instantiate the object with initial values for bool, int, float, and double
				var obj = new TestObjectPrimitives(done: true, i: 100, f: 5.55f, d: 9.999);
				// Test get methods
				if (obj.getBool() != true || obj.getInt() != 100 || obj.getFloat() != 5.55f || obj.getDouble() != 9.999)
					throw new Exception("TestObjectPrimitives.get() failed");
				// Test set methods
				obj.setBool(false);
				if (obj.getBool() != false)
					throw new Exception("TestObjectPrimitives.setBool() failed");
				obj.setInt(200);
				if (obj.getInt() != 200)
					throw new Exception("TestObjectPrimitives.setInt() failed");
				obj.setFloat(6.66f);
				if (obj.getFloat() != 6.66f)
					throw new Exception("TestObjectPrimitives.setFloat() failed");
				obj.setDouble(8.888);
				if (obj.getDouble() != 8.888)
					throw new Exception("TestObjectPrimitives.setDouble() failed");
			}
			// get/set with optional primitive types
			{
				// Instantiate the object with initial values for bool, int, float, and double
				var obj = new TestObjectPrimitives(done: true, i: 100, f: 5.55f, d: 9.999);
				// Test set methods with optional values
				obj.setBoolOpt(false);
				if (obj.getBoolOpt() != false)
					throw new Exception("TestObjectPrimitives.setBoolOpt() failed");
				obj.setBoolOpt(null);
				if (obj.getBoolOpt() != null)
					throw new Exception("TestObjectPrimitives.setBoolOpt() failed");
				obj.setIntOpt(200);
				if (obj.getIntOpt() != 200)
					throw new Exception("TestObjectPrimitives.setIntOpt() failed");
				obj.setIntOpt(null);
				if (obj.getIntOpt() != null)
					throw new Exception("TestObjectPrimitives.setIntOpt() failed");
				obj.setFloatOpt(6.66f);
				if (obj.getFloatOpt() != 6.66f)
					throw new Exception("TestObjectPrimitives.setFloatOpt() failed");
				obj.setFloatOpt(null);
				if (obj.getFloatOpt() != null)
					throw new Exception("TestObjectPrimitives.setFloatOpt() failed");
				obj.setDoubleOpt(8.888);
				if (obj.getDoubleOpt() != 8.888)
					throw new Exception("TestObjectPrimitives.setDoubleOpt() failed");
				obj.setDoubleOpt(null);
				if (obj.getDoubleOpt() != null)
					throw new Exception("TestObjectPrimitives.setDoubleOpt() failed");
			}
			// nullopt
			{
				// Instantiate the object with initial values for bool, int, float, and double
				var obj = new TestObjectPrimitives(done: false, i: 109, f: 90.90f, d: 100.100);
				// getNullopt
				if (obj.getNullopt() != null)
					throw new Exception("TestObjectPrimitives.getNullopt() failed");
			}
		}

		// Checking DirectedDefault
		{
			var testDefaultDirected = new TestObjectDirected();
			// Test with a valid integer (uint32_t)
			{
				string result = testDefaultDirected.doValueOptionalChanged(42);
				if (result != "")
					throw new Exception("TestObjectDirected.doValueOptionalChanged() failed");
			}
			// Test with null to simulate std::optional being empty
			{
				string result = testDefaultDirected.doValueOptionalChanged(null);
				if (result != "")
					throw new Exception("TestObjectDirected.doValueOptionalChanged() failed");
			}
			// Test with a valid integer (uint32_t) for reference
			{
				string result = testDefaultDirected.doReferenceOptionalChanged(42);
				if (result != "")
					throw new Exception("TestObjectDirected.doValueOptionalChangedRef() failed");
			}
			// Test with null to simulate std::optional reference being empty
			{
				string result = testDefaultDirected.doReferenceOptionalChanged(null);
				if (result != "")
					throw new Exception("TestObjectDirected.doValueOptionalChangedRef() failed");
			}
			// Create a Rect object and test with a valid Rect instance
			{
				var rect = new Rect(5.0, 3.0);
				string result = testDefaultDirected.onClassReferenceOptionalChanged(rect);
				if (result != "")
					throw new Exception("TestObjectDirected.onClassReferenceOptionalChanged() failed");
			}
			// Test with null to simulate std::optional being empty
			{
				string result = testDefaultDirected.onClassReferenceOptionalChanged(null);
				if (result != "")
					throw new Exception("TestObjectDirected.onClassReferenceOptionalChanged() failed");
			}
		}

		// Checking object instantiation
		{
			{
				var stru = new NoNamespaceStruct();
				stru.a = 42;
				if (stru.a != 42)
					throw new Exception("NoNamespaceStruct instantiation failed");
			}
			{
				var stru = new Struct();
				stru.a = 42;
				stru.b = 84;
				if (stru.a != 42 || stru.b != 84)
					throw new Exception("Struct instantiation failed");
			}
		}
	}
}
