package utils {
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;

    public function getClass(object:Object):Class {
        return Class(getDefinitionByName(getQualifiedClassName(object)));
    }
}
