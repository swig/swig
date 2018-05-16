%module(directors="1") director_ownership

// Github issue #1184

%include "std_string.i"

%feature("director") example::ContentBase;
%feature("director") example::ContentDerived;

%newobject example::make_content;

%inline %{
#include <string>

namespace example
{

class ContentBase
{
public:
    ContentBase() {}
    virtual ~ContentBase() {}
    virtual std::string get_name() const = 0;
};


class ContentDerived: public ContentBase
{
public:
    ContentDerived():ContentBase() { m_name = "ContentDerived"; }
    virtual ~ContentDerived() {}
    virtual std::string get_name() const { return m_name; }

private:
    std::string m_name;
};


class Container
{
public:
    Container() { m_content = 0; }
    ~Container()
    {
        clear_content();
    }
    // the container takes the ownership of the content
    void set_content(ContentBase* content)
    {
        clear_content();
        m_content = content;
    }
    ContentBase* get_content() { return m_content; }

private:
    void clear_content()
    {
        if(m_content)
        {
            delete m_content;
            m_content = 0;
        }
    }
    
private:
    ContentBase* m_content;
};

static ContentBase* make_content() { return new ContentDerived(); }

} // namespace example
%}
