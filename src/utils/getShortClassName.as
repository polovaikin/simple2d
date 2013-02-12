package utils {
    import flash.utils.getQualifiedClassName;

    public function getShortClassName(object:Object):String {
        var name:String = getQualifiedClassName(object);
        return name.substring(name.indexOf("::", 0) + 2, name.length);
    }
}
