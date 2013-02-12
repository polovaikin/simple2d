package utils {

    public function removeItemFromList(list:Object, item:Object):void {
        var index:int = list.indexOf(item);
        if (index > -1) {
            list.splice(index, 1);
        }
    }

}