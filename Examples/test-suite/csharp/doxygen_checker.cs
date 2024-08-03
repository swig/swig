using System;
using System.Xml;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;

/// Class used to check XML documentation content generated 
/// by C# compiler for Doxygen tests.
/// Methods allow to look for the documentation of a specific object (method, type, variable) 
/// and to check its content.
public class doxygen_checker{

    private XmlElement _root;
    private string _namespace_prefix;

    /// Enum to identify the different types of objects in XML
    public enum CodeType
    {
        /// <summary>member of a class/type</summary>
        MEMBER, 
        /// <summary>class/type itself</summary>
        TYPE  
    };

    /// <summary> Constructor </summary>
    ///
    /// <param name="namespaceName"> The name of namespace to consider </param>
    /// <param name="className"> The name of the class inside the namespace </param>
    /// <param name="xmlFilePath"> The file path where the XML to parse is located</param>
    public doxygen_checker(string namespaceName, string className, string xmlFilePath)
    {
        XmlDocument doc = new XmlDocument();

        string fileContent;
        try{
            fileContent = File.ReadAllText(xmlFilePath);
        }
        catch (Exception e)
        {
            throw new ApplicationException("Error: " + e.Message);
        }

        doc.LoadXml(fileContent);
        _root = doc.DocumentElement; //get the root element.
        _namespace_prefix = namespaceName +"Namespace." +  className + ".";
    }

    /// <summary>Check general content (not included in a tag) of an object </summary>
    ///
    /// <param name="codeType"> The type of object to check </param>
    /// <param name="objectName"> The name of the object (function mostly) to check </param>
    /// <param name="expectedContent"> The content of the documentation for the given object </param>
    /// <exception cref="ApplicationException"> When object or expected content is not found </exception>
    public void checkText(CodeType codeType, string objectName, string expectedContent)
   {
       string completeObjectName = _createObjectName(codeType, objectName);
       bool found = false;

       _root.SelectNodes("members/member").Cast<XmlElement>().ToList().ForEach(member =>
       {
           if (member.Attributes["name"].Value == completeObjectName)
           {
               found = true;

               // parse all children of member until #text is found
               string valMember = member.ChildNodes.Cast<XmlNode>().ToList().Find(node => node.Name == "#text").InnerText;

               if (uniformizeString(expectedContent) != uniformizeString(valMember))
               {
                   throw new ApplicationException("Error: " + objectName + " contains '" + valMember + "', expected '" + expectedContent + "'");
               }
               return;
           }
       });

       if (!found)
           throw new ApplicationException("Object '" + objectName + "' not found");
   }

    /// <summary>Check field content from an object</summary>
    ///
    /// <param name="codeType">The type of object to check </param>
    /// <param name="objectName">The name of object (function mostly) to check </param>
    /// <param name="fieldName">The name of the XML tag (summary, param,...) of the object to check </param>
    /// <param name="itemIndex"> The index of the field (0 for the first one, 1 for the second, etc) to check </param>
    /// <param name="expectedContent"> The content of the documentation for the given object </param>
    /// <exception cref="ApplicationException"> When object, field, or expected content is not found </exception>
    public void checkObject(CodeType codeType, string objectName, string fieldName, int itemIndex, string expectedContent)
    {
        string completeObjectName = _createObjectName(codeType, objectName);
        bool found = false;

        _root.SelectNodes("members/member").Cast<XmlElement>().ToList().ForEach(member =>
        {
            if (member.Attributes["name"].Value == completeObjectName)
            {
                found = true;
                var field = member.SelectNodes(fieldName);

                if (field == null)
                    throw new ApplicationException("Field " + fieldName + " is not found");

                if (itemIndex >= field.Count)
                {
                    throw new ApplicationException("Error: " + objectName + " has " + field.Count + " fields, "+ itemIndex +"th value does not exist");
                }
                else
                {
                    var valField = field.Item(itemIndex).InnerText;

                    if (uniformizeString(expectedContent) != uniformizeString(valField))
                    {
                        throw new ApplicationException("Error: " + objectName + " field '" + fieldName + "' is '" + valField + "', expected '" + expectedContent + "'");
                    }
                }
                return;
            }
        });

        if(!found)
                throw new ApplicationException("Object '" + objectName + "' not found" );
    }

    private string _createObjectName(CodeType codeType, string objectName)
    {
        if(codeType == CodeType.MEMBER)
            return "M:" + _namespace_prefix + objectName;
        else
            return "T:" + _namespace_prefix + objectName;
    }

    /// Returns a string without break lines so as to avoid issues during string comparison
    private string uniformizeString(string str)
    {
        // remove line breaks in string
        if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
            return Regex.Replace(str, @"\t|\n|\r", "");
        else
            return Regex.Replace(str, @"\s|\n|\r", "");
    }

    /// <summary> Check field attribute from an object </summary>
    ///
    /// <param name="codeType">The type of object to check </param>
    /// <param name="objectName">The name of object (function mostly) to check </param>
    /// <param name="fieldName">The name of the XML tag (summary, param,...) of the object to check </param>
    /// <param name="itemIndex"> The index of the field (0 for the first one, 1 for the second, etc) to check </param>
    /// <param name="attributeName"> The XML attribute to consider </param>
    /// <param name="expectedContent"> The content of the documentation for the given object </param>
    /// <exception cref="ApplicationException"> When object, field, attribute or expected content is not found </exception>
    public void checkObjectAttribute(CodeType codeType, string objectName, string fieldName, int itemIndex, string attributeName, string expectedContent)
    {
        string completeObjectName = _createObjectName(codeType, objectName);
        bool found = false;

        _root.SelectNodes("members/member").Cast<XmlElement>().ToList().ForEach(member =>
        {
            if (member.Attributes["name"].Value == completeObjectName)
            {
                found = true;
                var field = member.SelectNodes(fieldName);

                if (field == null)
                    throw new ApplicationException("Field " + fieldName + " is not found");

                if(field.Count == 0)
                    throw new ApplicationException("Field " + fieldName + " is empty");

                // read attribute of first field's item
                string valItem = field.Item(itemIndex).Attributes[attributeName].Value;

                if(uniformizeString(valItem) != uniformizeString(expectedContent))
                    throw new ApplicationException("Error: " + objectName + " field " + fieldName + " is '" + valItem + "', expected '" + expectedContent + "'");

                return;
            }
        });

        if (!found)
            throw new ApplicationException("Object '" + objectName + "' not found");
    }
}
