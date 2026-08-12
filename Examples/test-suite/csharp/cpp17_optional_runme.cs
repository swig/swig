//#define USE_NULLABLE_REFERENCE_TYPES // Enable this to use nullable reference types for optional class types in C# (requires C# 8.0 or later) - SWIG_STD_OPTIONAL_USE_NULLABLE_REFERENCE_TYPES must be defined in the interface file

using System;
using cpp17_optionalNamespace;

// Director implementation for testing optional types (all methods take and return std::optional<T>)
class MyDirectedObject : TestObjectDirected
{
	// uint32_t optional - returns input + 1 if has value, otherwise nullopt
	public override uint? onUint32OptionalChanged(uint? value)
	{
		return value.HasValue ? value.Value + 1 : (uint?)null;
	}

	// If nullable reference types are supported (C# 8.0+) - SWIG_STD_OPTIONAL_USE_NULLABLE_REFERENCE_TYPES must be defined
#if USE_NULLABLE_REFERENCE_TYPES
	// Rect optional - returns a new Rect with doubled dimensions if has value, otherwise nullopt
	public override Rect? onRectOptionalChanged(Rect? value)
	{
		if (value != null)
			return new Rect(value.width * 2, value.height * 2);
		return null;
	}

	// string optional - returns uppercased string if has value, otherwise nullopt
	public override string? onStringOptionalChanged(string? value)
	{
		return value != null ? value.ToUpper() : null;
	}
#else
	// Rect optional - returns a new Rect with doubled dimensions if has value, otherwise nullopt
	public override Rect onRectOptionalChanged(Rect value)
	{
		if (value != null)
			return new Rect(value.width * 2, value.height * 2);
		return null;
	}

	// string optional - returns uppercased string if has value, otherwise nullopt
	public override string onStringOptionalChanged(string value)
	{
		return value != null ? value.ToUpper() : null;
	}
#endif

	// int optional - returns input * 2 if has value, otherwise nullopt
	public override int? onIntOptionalChanged(int? value)
	{
		return value.HasValue ? value.Value * 2 : (int?)null;
	}

	// SmallEnum optional - returns next enum value if has value, otherwise nullopt
	public override SmallEnum? onSmallEnumOptionalChanged(SmallEnum? value)
	{
		if (!value.HasValue)
			return null;
		// Return next value (wrap around)
		if (value.Value == SmallEnum.Value1)
			return SmallEnum.Value2;
		if (value.Value == SmallEnum.Value2)
			return SmallEnum.Value3;
		return SmallEnum.Value1;
	}

	// BigEnum optional - returns same value if has value, otherwise nullopt
	public override BigEnum? onBigEnumOptionalChanged(BigEnum? value)
	{
		return value; // Just echo back to test round-trip
	}
}

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
				var structObj = new Struct { a = 56u, b = 78u, sub = new SubStruct { z = 99u }, bigEnumOpt = BigEnum.Large, aliasEnumOpt = 1234567890123456789 };
				testOptionals.setStructOptional(structObj);
				var optStruct = testOptionals.getStructOptional();
				if (optStruct == null)
					throw new Exception("TestOptionals.setStructOptional() failed");
				if (optStruct?.a != 56u || optStruct?.b != 78u || optStruct?.sub.z != 99u || optStruct?.bigEnumOpt != BigEnum.Large || optStruct?.aliasEnumOpt != 1234567890123456789)
					throw new Exception("TestOptionals.setStructOptional() failed");
				var optStructCopy = testOptionals.getStructOptionalCopy();
				if (optStructCopy == null)
					throw new Exception("TestOptionals.setStructOptional() failed");
				if (optStructCopy?.a != 56u || optStructCopy?.b != 78u || optStructCopy?.sub.z != 99u || optStructCopy?.bigEnumOpt != BigEnum.Large || optStructCopy?.aliasEnumOpt != 1234567890123456789)
					throw new Exception("TestOptionals.setStructOptional() failed");
				// Test struct modifier
				structObj.a = 4u;
				structObj.b = 2u;
				structObj.sub.z = 1u;
				structObj.bigEnumOpt = BigEnum.Small;
				structObj.aliasEnumOpt = 987654321098765432;
				testOptionals.setStructOptional(structObj);
				if (optStruct?.a != 4u || optStruct?.b != 2u || optStruct?.sub?.z != 1u || optStruct?.bigEnumOpt != BigEnum.Small || optStruct?.aliasEnumOpt != 987654321098765432)
					throw new Exception("TestOptionals.setStructOptional() failed");
				if (optStructCopy?.a != 56u || optStructCopy?.b != 78u || optStructCopy?.sub?.z != 99u || optStructCopy?.bigEnumOpt != BigEnum.Large || optStructCopy?.aliasEnumOpt != 1234567890123456789)
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

		// Checking DirectedDefault (base class returns nullopt by default)
		{
			var testDefaultDirected = new TestObjectDirected();
			// Test with a valid integer (uint32_t)
			{
				uint? result = testDefaultDirected.doUint32OptionalChanged(42);
				if (result != null)
					throw new Exception("TestObjectDirected.doUint32OptionalChanged() should return null");
			}
			// Test with null to simulate std::optional being empty
			{
				uint? result = testDefaultDirected.doUint32OptionalChanged(null);
				if (result != null)
					throw new Exception("TestObjectDirected.doUint32OptionalChanged(null) should return null");
			}
			// If nullable reference types are supported (C# 8.0+) - SWIG_STD_OPTIONAL_USE_NULLABLE_REFERENCE_TYPES must be defined
#if USE_NULLABLE_REFERENCE_TYPES
			// Test with a valid Rect
			{
				var rect = new Rect(10.0f, 20.0f);
				Rect? result = testDefaultDirected.doRectOptionalChanged(rect);
				if (result != null)
					throw new Exception("TestObjectDirected.doRectOptionalChanged() should return null");
			}
			// Test string optional
			{
				string? result = testDefaultDirected.doStringOptionalChanged("test");
				if (result != null)
					throw new Exception("TestObjectDirected.doStringOptionalChanged() should return null");
			}
#else
			// Test with a valid Rect
			{
				var rect = new Rect(10.0f, 20.0f);
				Rect result = testDefaultDirected.doRectOptionalChanged(rect);
				if (result != null)
					throw new Exception("TestObjectDirected.doRectOptionalChanged() should return null");
			}
			// Test string optional
			{
				string result = testDefaultDirected.doStringOptionalChanged("test");
				if (result != null)
					throw new Exception("TestObjectDirected.doStringOptionalChanged() should return null");
			}
#endif
			// Test SmallEnum optional
			{
				SmallEnum? result = testDefaultDirected.doSmallEnumOptionalChanged(SmallEnum.Value1);
				if (result != null)
					throw new Exception("TestObjectDirected.doSmallEnumOptionalChanged() should return null");
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

		// Checking TestEnums (enum class with different underlying types)
		{
			var testEnums = new TestEnums();

			// SmallEnum (uint8_t underlying type)
			{
				// Initially null
				if (testEnums.getSmallEnumOpt() != null)
					throw new Exception("TestEnums.getSmallEnumOpt() should be null initially");

				// Set to Value1
				testEnums.setSmallEnumOpt(SmallEnum.Value1);
				if (testEnums.getSmallEnumOpt() != SmallEnum.Value1)
					throw new Exception("TestEnums.setSmallEnumOpt(Value1) failed");

				// Set to Value3 (max value 255)
				testEnums.setSmallEnumOpt(SmallEnum.Value3);
				if (testEnums.getSmallEnumOpt() != SmallEnum.Value3)
					throw new Exception("TestEnums.setSmallEnumOpt(Value3) failed");

				// Set back to null
				testEnums.setSmallEnumOpt(null);
				if (testEnums.getSmallEnumOpt() != null)
					throw new Exception("TestEnums.setSmallEnumOpt(null) failed");
			}

			// BigEnum (uint64_t underlying type)
			{
				// Initially null
				if (testEnums.getBigEnumOpt() != null)
					throw new Exception("TestEnums.getBigEnumOpt() should be null initially");

				// Set to Small (negative large value)
				testEnums.setBigEnumOpt(BigEnum.Small);
				if (testEnums.getBigEnumOpt() != BigEnum.Small)
					throw new Exception("TestEnums.setBigEnumOpt(Small) failed");

				// Set to Large (positive large value)
				testEnums.setBigEnumOpt(BigEnum.Large);
				if (testEnums.getBigEnumOpt() != BigEnum.Large)
					throw new Exception("TestEnums.setBigEnumOpt(Large) failed");

				// Set to Zero
				testEnums.setBigEnumOpt(BigEnum.Zero);
				if (testEnums.getBigEnumOpt() != BigEnum.Zero)
					throw new Exception("TestEnums.setBigEnumOpt(Zero) failed");

				// Set back to null
				testEnums.setBigEnumOpt(null);
				if (testEnums.getBigEnumOpt() != null)
					throw new Exception("TestEnums.setBigEnumOpt(null) failed");
			}
		}

		// Checking Director with derived class (all methods take and return std::optional<T>)
		{
			var myDirected = new MyDirectedObject();

			// Test uint32_t optional director (returns input + 1)
			{
				uint? result = myDirected.doUint32OptionalChanged(42);
				if (result != 43)
					throw new Exception("MyDirectedObject.doUint32OptionalChanged(42) failed: expected 43, got " + result);

				result = myDirected.doUint32OptionalChanged(0);
				if (result != 1)
					throw new Exception("MyDirectedObject.doUint32OptionalChanged(0) failed: expected 1, got " + result);

				result = myDirected.doUint32OptionalChanged(null);
				if (result != null)
					throw new Exception("MyDirectedObject.doUint32OptionalChanged(null) failed: expected null, got " + result);
			}

			// Test int optional director (returns input * 2)
			{
				int? result = myDirected.doIntOptionalChanged(42);
				if (result != 84)
					throw new Exception("MyDirectedObject.doIntOptionalChanged(42) failed: expected 84, got " + result);

				result = myDirected.doIntOptionalChanged(-100);
				if (result != -200)
					throw new Exception("MyDirectedObject.doIntOptionalChanged(-100) failed: expected -200, got " + result);

				result = myDirected.doIntOptionalChanged(null);
				if (result != null)
					throw new Exception("MyDirectedObject.doIntOptionalChanged(null) failed: expected null, got " + result);
			}

			// If nullable reference types are supported (C# 8.0+) - SWIG_STD_OPTIONAL_USE_NULLABLE_REFERENCE_TYPES must be defined
#if USE_NULLABLE_REFERENCE_TYPES
			// Test with a valid Rect
			{
				Rect? result = myDirected.doRectOptionalChanged(new Rect(10.0f, 20.0f));
				if (result == null || result.width != 20.0f || result.height != 40.0f)
					throw new Exception("MyDirectedObject.doRectOptionalChanged(Rect(10,20)) failed: expected Rect(20,40), got " + result);

				result = myDirected.doRectOptionalChanged(null);
				if (result != null)
					throw new Exception("MyDirectedObject.doRectOptionalChanged(null) failed: expected null, got " + result);
			}
			// Test string optional director (returns uppercased string)
			{
				string? result = myDirected.doStringOptionalChanged("hello");
				if (result != "HELLO")
					throw new Exception("MyDirectedObject.doStringOptionalChanged(hello) failed: expected HELLO, got " + result);

				result = myDirected.doStringOptionalChanged(null);
				if (result != null)
					throw new Exception("MyDirectedObject.doStringOptionalChanged(null) failed: expected null, got " + result);
			}
#else
			// Test with a valid Rect
			{
				Rect result = myDirected.doRectOptionalChanged(new Rect(10.0f, 20.0f));
				if (result == null || result.width != 20.0f || result.height != 40.0f)
					throw new Exception("MyDirectedObject.doRectOptionalChanged(Rect(10,20)) failed: expected Rect(20,40), got " + result);

				result = myDirected.doRectOptionalChanged(null);
				if (result != null)
					throw new Exception("MyDirectedObject.doRectOptionalChanged(null) failed: expected null, got " + result);
			}
			// Test string optional director (returns uppercased string)
			{
				string result = myDirected.doStringOptionalChanged("hello");
				if (result != "HELLO")
					throw new Exception("MyDirectedObject.doStringOptionalChanged(hello) failed: expected HELLO, got " + result);

				result = myDirected.doStringOptionalChanged(null);
				if (result != null)
					throw new Exception("MyDirectedObject.doStringOptionalChanged(null) failed: expected null, got " + result);
			}
#endif

			// Test SmallEnum optional director (returns next enum value)
			{
				SmallEnum? result = myDirected.doSmallEnumOptionalChanged(SmallEnum.Value1);
				if (result != SmallEnum.Value2)
					throw new Exception("MyDirectedObject.doSmallEnumOptionalChanged(Value1) failed: expected Value2, got " + result);

				result = myDirected.doSmallEnumOptionalChanged(SmallEnum.Value2);
				if (result != SmallEnum.Value3)
					throw new Exception("MyDirectedObject.doSmallEnumOptionalChanged(Value2) failed: expected Value3, got " + result);

				result = myDirected.doSmallEnumOptionalChanged(SmallEnum.Value3);
				if (result != SmallEnum.Value1)
					throw new Exception("MyDirectedObject.doSmallEnumOptionalChanged(Value3) failed: expected Value1, got " + result);

				result = myDirected.doSmallEnumOptionalChanged(null);
				if (result != null)
					throw new Exception("MyDirectedObject.doSmallEnumOptionalChanged(null) failed: expected null, got " + result);
			}

			// Test BigEnum optional director (echo back)
			{
				BigEnum? result = myDirected.doBigEnumOptionalChanged(BigEnum.Large);
				if (result != BigEnum.Large)
					throw new Exception("MyDirectedObject.doBigEnumOptionalChanged(Large) failed: expected Large, got " + result);

				result = myDirected.doBigEnumOptionalChanged(BigEnum.Small);
				if (result != BigEnum.Small)
					throw new Exception("MyDirectedObject.doBigEnumOptionalChanged(Small) failed: expected Small, got " + result);

				result = myDirected.doBigEnumOptionalChanged(BigEnum.Zero);
				if (result != BigEnum.Zero)
					throw new Exception("MyDirectedObject.doBigEnumOptionalChanged(Zero) failed: expected Zero, got " + result);

				result = myDirected.doBigEnumOptionalChanged(null);
				if (result != null)
					throw new Exception("MyDirectedObject.doBigEnumOptionalChanged(null) failed: expected null, got " + result);
			}
		}
		// Force garbage collection to ensure proper cleanup of SWIG objects (and detect bad memory management if any)
		GC.Collect();
		GC.WaitForPendingFinalizers();
	}
}
