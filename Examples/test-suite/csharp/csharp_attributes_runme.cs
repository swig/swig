using System;
using System.Reflection;
using csharp_attributesNamespace;

public class runme
{
  static void Main() 
  {
    // Custom attributes typemap tests
    //
    // cstype typemap attributechecks
    //
    // Global function cstype typemap attributes check
    csharp_attributes csharpattributes = new csharp_attributes();
    Type globaltype = csharpattributes.GetType();
    {
      MethodInfo member = (MethodInfo)globaltype.GetMember("GlobalFunction")[0];
      if (Attribute.GetCustomAttribute(member, typeof(IntOutAttribute)) == null)
        throw new Exception("No IntOut attribute for " + member.Name);
      ParameterInfo parameter = member.GetParameters()[0]; // expecting one parameter
      if (parameter.Name != "myInt")
        throw new Exception("Incorrect parameter name");
      Attribute attribute = Attribute.GetCustomAttributes(parameter)[0];
      if (attribute.GetType() != typeof(IntInAttribute))
        throw new Exception("Expecting IntIn attribute");
    }
    // Constant - cstype typemap attributes check
    {
      MemberInfo member = (MemberInfo)globaltype.GetMember("TESTMACRO")[0];
      if (Attribute.GetCustomAttribute(member, typeof(IntOutAttribute)) == null)
        throw new Exception("No IntOut attribute for " + member.Name);
    }

    // Non-static method cstype typemap attributes check
    Stations testClass = new Stations(20);
    Type type = testClass.GetType();
    {
      MethodInfo member = (MethodInfo)type.GetMember("Reading")[0];
      if (Attribute.GetCustomAttribute(member, typeof(IntOutAttribute)) == null)
        throw new Exception("No IntOut attribute for " + member.Name);
      ParameterInfo parameter = member.GetParameters()[0]; // expecting one parameter
      if (parameter.Name != "myInt")
        throw new Exception("Incorrect parameter name");
      Attribute attribute = Attribute.GetCustomAttributes(parameter)[0];
      if (attribute.GetType() != typeof(IntInAttribute))
        throw new Exception("Expecting IntIn attribute");
    }
    // Static method cstype typemap attributes check
    {
      MethodInfo member = (MethodInfo)type.GetMember("Swindon")[0];
      if (Attribute.GetCustomAttribute(member, typeof(IntOutAttribute)) == null)
        throw new Exception("No IntOut attribute for " + member.Name);
      ParameterInfo parameter = member.GetParameters()[0]; // expecting one parameter
      if (parameter.Name != "myInt")
        throw new Exception("Incorrect parameter name");
      Attribute attribute = Attribute.GetCustomAttributes(parameter)[0];
      if (attribute.GetType() != typeof(IntInAttribute))
        throw new Exception("Expecting IntIn attribute");
    }
    // Constructor cstype typemap attributes check
    {
      ConstructorInfo member = (ConstructorInfo)type.GetConstructors()[0];
      ParameterInfo parameter = member.GetParameters()[0]; // expecting one parameter
      if (parameter.Name != "myInt")
        throw new Exception("Incorrect parameter name");
      Attribute attribute = Attribute.GetCustomAttributes(parameter)[0];
      if (attribute.GetType() != typeof(IntInAttribute))
        throw new Exception("Expecting IntIn attribute");
    }

    //
    // imtype typemap attributechecks
    //
    // Global function imtype typemap attributes check
    csharp_attributesPINVOKE csPinvoke = new csharp_attributesPINVOKE();
    Type imclasstype = csPinvoke.GetType();
    {
      MethodInfo member = (MethodInfo)imclasstype.GetMember("GlobalFunction")[0];
      if (Attribute.GetCustomAttribute(member, typeof(IntegerOutAttribute)) == null)
        throw new Exception("No IntegerOut attribute for " + member.Name);
      ParameterInfo parameter = member.GetParameters()[0]; // checking 1st parameter
      Attribute attribute = Attribute.GetCustomAttributes(parameter)[0];
      if (attribute.GetType() != typeof(IntegerInAttribute))
        throw new Exception("Expecting IntegerIn attribute");
    }
    // Constant - imtype typemap attributes check
    {
      MethodInfo member = (MethodInfo)imclasstype.GetMember("get_TESTMACRO")[0];
      if (Attribute.GetCustomAttribute(member, typeof(IntegerOutAttribute)) == null)
        throw new Exception("No IntegerOut attribute for " + member.Name);
    }
    // Non-static method imtype typemap attributes check
    {
      MethodInfo member = (MethodInfo)imclasstype.GetMember("Stations_Reading")[0];
      if (Attribute.GetCustomAttribute(member, typeof(IntegerOutAttribute)) == null)
        throw new Exception("No IntegerOut attribute for " + member.Name);
      ParameterInfo parameter = member.GetParameters()[1]; // checking 2nd parameter
      Attribute attribute = Attribute.GetCustomAttributes(parameter)[0];
      if (attribute.GetType() != typeof(IntegerInAttribute))
        throw new Exception("Expecting IntegerIn attribute");
    }
    // Static method imtype typemap attributes check
    {
      MethodInfo member = (MethodInfo)imclasstype.GetMember("Stations_Swindon")[0];
      if (Attribute.GetCustomAttribute(member, typeof(IntegerOutAttribute)) == null)
        throw new Exception("No IntegerOut attribute for " + member.Name);
      ParameterInfo parameter = member.GetParameters()[0]; // checking 1st parameter
      Attribute attribute = Attribute.GetCustomAttributes(parameter)[0];
      if (attribute.GetType() != typeof(IntegerInAttribute))
        throw new Exception("Expecting IntegerIn attribute");
    }

    //
    // attributes feature
    //
    MoreStations moreStations = new MoreStations();
    Type moretype = moreStations.GetType();

    // Constructor attributes feature check
    {
      ConstructorInfo member = (ConstructorInfo)moretype.GetConstructors()[0];
      if (Attribute.GetCustomAttribute(member, typeof(InterCity1Attribute)) == null)
        throw new Exception("MoreStations::MoreStations attribute failed");
    }
    // Non-static method attributes feature check
    {
      MethodInfo member = (MethodInfo)moretype.GetMember("Chippenham")[0];
      if (Attribute.GetCustomAttribute(member, typeof(InterCity2Attribute)) == null)
        throw new Exception("MoreStations::Chippenham attribute failed");
    }
    // Static method attributes feature check
    {
      MethodInfo member = (MethodInfo)moretype.GetMember("Bath")[0];
      if (Attribute.GetCustomAttribute(member, typeof(InterCity3Attribute)) == null)
        throw new Exception("MoreStations::Bath attribute failed");
    }
    // Non-static member variable attributes feature check
    {
      PropertyInfo member = (PropertyInfo)moretype.GetProperty("Bristol");
      if (Attribute.GetCustomAttribute(member, typeof(InterCity4Attribute)) == null)
        throw new Exception("MoreStations::Bristol attribute failed");
    }
    // Static member variable attributes feature check
    {
      PropertyInfo member = (PropertyInfo)moretype.GetProperty("WestonSuperMare");
      if (Attribute.GetCustomAttribute(member, typeof(InterCity5Attribute)) == null)
        throw new Exception("MoreStations::Bristol attribute failed");
    }
    // Global function attributes feature check
    {
      MethodInfo member = (MethodInfo)globaltype.GetMember("Paddington")[0];
      if (Attribute.GetCustomAttribute(member, typeof(InterCity7Attribute)) == null)
        throw new Exception("MoreStations::Paddington attribute failed");
    }
    // Global variables attributes feature check
    {
      PropertyInfo member = (PropertyInfo)globaltype.GetProperty("DidcotParkway");
      if (Attribute.GetCustomAttribute(member, typeof(InterCity8Attribute)) == null)
        throw new Exception("MoreStations::Paddington attribute failed");
    }

    //
    // csattribute typemaps
    //
    // Class csattribute typemap
    {
      Object[] attribs = moretype.GetCustomAttributes(true);
      Eurostar1Attribute tgv = (Eurostar1Attribute)attribs[0];
      if (tgv == null)
        throw new Exception("No attribute for MoreStations");
    }
    // Nested enum csattribute typemap
    {
      MemberInfo member = (MemberInfo)moretype.GetMember("Wales")[0];
      if (Attribute.GetCustomAttribute(member, typeof(Eurostar2Attribute)) == null)
        throw new Exception("No attribute for " + member.Name);
    }
    // Enum csattribute typemap
    {
      /* TODO
      Cymru cymru = new Cymru();
      Type cymrutype = Cymru.GetType();
      Object[] attribs = cymrutype.GetCustomAttributes(true);
      Eurostar3Attribute tgv = (Eurostar3Attribute)attribs[0];
      if (tgv == null)
        throw new Exception("No attribute for Cymru");
      */
    }
  }
}

// Custom attribute classes
[AttributeUsage(AttributeTargets.All, Inherited = false, AllowMultiple = true)]
public class IntInAttribute : Attribute {}

[AttributeUsage(AttributeTargets.All, Inherited = false, AllowMultiple = true)]
public class IntOutAttribute : Attribute {}

[AttributeUsage(AttributeTargets.All, Inherited = false, AllowMultiple = true)]
public class IntegerInAttribute : Attribute {}

[AttributeUsage(AttributeTargets.All, Inherited = false, AllowMultiple = true)]
public class IntegerOutAttribute : Attribute {}


[AttributeUsage(AttributeTargets.All, Inherited = false, AllowMultiple = true)]
public class InterCity1Attribute : Attribute {}

[AttributeUsage(AttributeTargets.All, Inherited = false, AllowMultiple = true)]
public class InterCity2Attribute : Attribute {}

[AttributeUsage(AttributeTargets.All, Inherited = false, AllowMultiple = true)]
public class InterCity3Attribute : Attribute {}

[AttributeUsage(AttributeTargets.All, Inherited = false, AllowMultiple = true)]
public class InterCity4Attribute : Attribute {}

[AttributeUsage(AttributeTargets.All, Inherited = false, AllowMultiple = true)]
public class InterCity5Attribute : Attribute {}

[AttributeUsage(AttributeTargets.All, Inherited = false, AllowMultiple = true)]
public class InterCity6Attribute : Attribute {}

[AttributeUsage(AttributeTargets.All, Inherited = false, AllowMultiple = true)]
public class InterCity7Attribute : Attribute {}

[AttributeUsage(AttributeTargets.All, Inherited = false, AllowMultiple = true)]
public class InterCity8Attribute : Attribute {}


[AttributeUsage(AttributeTargets.All, Inherited = false, AllowMultiple = true)]
public class Eurostar1Attribute : Attribute {}

[AttributeUsage(AttributeTargets.All, Inherited = false, AllowMultiple = true)]
public class Eurostar2Attribute : Attribute {}

[AttributeUsage(AttributeTargets.All, Inherited = false, AllowMultiple = true)]
public class Eurostar3Attribute : Attribute {}


[AttributeUsage(AttributeTargets.All, Inherited = false, AllowMultiple = true)]
public class ThreadSafeAttribute : Attribute {
  public ThreadSafeAttribute(bool safe) {}
  public ThreadSafeAttribute() {}
}

