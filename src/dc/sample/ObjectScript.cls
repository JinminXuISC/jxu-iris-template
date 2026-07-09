Class dc.sample.ObjectScript Extends %RegisteredObject
{

/// A simple sanity-check method.
///   do ##class(dc.sample.ObjectScript).Test()
ClassMethod Test() As %Status
{
    write "Hello from the IRISDEV namespace!", !
    write "Current namespace: ", $namespace, !
    return $$$OK
}

}
