package com.pop136.puzzle.ui {
import com.pop136.puzzle.Config;
import com.pop136.puzzle.event.CanvasEvent;
import com.pop136.puzzle.event.CommonDialogEvent;
import com.pop136.puzzle.event.Messager;
import com.pop136.puzzle.manager.DataManager;

import flash.display.MovieClip;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.setTimeout;

public class Canvas extends Sprite {

    public static const AUTO:String = 'auto';
    public static const HORIZONTAL:String = 'horizontal';
    public static const VERTICAL:String = 'vertical';
    public static const LEFT:String = 'left';
    public static const RIGHT:String = 'right';
    public static const TOP:String = 'top';
    public static const BOTTOM:String = 'bottom';
    public static const TYPE_GRID:String = 'typeGrid';
    public static const TYPE_LAYER:String = 'typeLayer';

    public var w:int;
    public var h:int;
    public var s:Number;

    public var gridContainer:Sprite;
    public var layerContainer:Sprite;
    public var layer:Layer;
    public var grid:Grid;

    private var side:String;
    private var arr1:Array = [];
    private var arr2:Array = [];

    private var border;

    private var messager:Messager = Messager.getInstance();

    public function Canvas() {
        super();

//        setLayer([{
//            x:0, y:0, width:675, height:481, photo:{big:"asset/image/layer/707bc95d51f3d63ec245cd180286e4c3.png", x:0, y:0, width:675, height:481, scale:1, rotation:0, brand:"", description:"", link:"", linkType:1, rank:1}
//        }]);

        addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
//        addEventListener(MouseEvent.CLICK, onClick);
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        messager.addEventListener(CommonDialogEvent.SAVE, onCommonDialogSave);
    }

    private function onCommonDialogSave(e:CommonDialogEvent){
        if(grid){
            grid.brand = e.data.brand;
            grid.description = e.data.description;
            grid.link = e.data.link;
            grid.linkType = e.data.linkType;
        }else if(layer){
            layer.brand = e.data.brand;
            layer.description = e.data.description;
            layer.link = e.data.link;
            layer.linkType = e.data.linkType;
        }
    }

    public function getGrids():Array{
        var arr:Array = [];
        for(var i:int=0;i<gridContainer.numChildren;i++){
            var grid = gridContainer.getChildAt(i);
            var obj = {
                x:grid.x,
                y:grid.y,
                width:grid.masker.width,
                height:grid.masker.height,
                rx:grid.x/Config.LAYOUT_WIDTH,
                ry:grid.y/Config.LAYOUT_HEIGHT,
                rw:grid.masker.width/Config.LAYOUT_WIDTH,
                rh:grid.masker.height/Config.LAYOUT_HEIGHT,
                photo:{
                    id:grid.id,
                    small:grid.small,
                    big:grid.big,
                    x:grid.container.x,
                    y:grid.container.y,
                    width:grid.container.width,
                    height:grid.container.height,
                    scale:grid.container.scaleX,
                    rotation:grid.container.rotation,
                    rotationX: grid.rx,
                    rotationY: grid.ry,
                    brand:grid.brand,
                    description:grid.description,
                    link:grid.link,
                    linkType:grid.linkType,
                    isLocal:grid.isLocal
                }
            };
            arr.push(obj);
        }
        return arr;
    }

    public function getLayers():Array{
        var arr:Array = [];
        for(var i:int=0;i<layerContainer.numChildren;i++){
            var layer = layerContainer.getChildAt(i);
            var obj = {
                x:layer.x,
                y:layer.y,
                width:layer.masker.width,
                height:layer.masker.height,
                rx:layer.x/Config.LAYOUT_WIDTH,
                ry:layer.y/Config.LAYOUT_HEIGHT,
                rw:layer.masker.width/Config.LAYOUT_WIDTH,
                rh:layer.masker.height/Config.LAYOUT_HEIGHT,
                photo:{
                    id:layer.id,
                    small:layer.small,
                    big:layer.big,
                    x:layer.container.x,
                    y:layer.container.y,
                    width:layer.container.width,
                    height:layer.container.height,
                    scale:layer.container.scaleX,
                    rotation:layer.container.rotation,
                    rotationX: layer.rx,
                    rotationY: layer.ry,
                    brand:layer.brand,
                    description:layer.description,
                    link:layer.link,
                    linkType:layer.linkType
                }
            };
            arr.push(obj);
        }
        return arr;
    }

    private function onMouseDown(e:MouseEvent):void{

        onClick(e);
        if(e.target.name=='topMc' || e.target.name=='rightMc' || e.target.name=='bottomMc' || e.target.name=='leftMc'){
            addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            border = e.target;
            side = border.name.substring(0, border.name.indexOf('Mc'));
            checkResizeGrids();
            if(Main.mergeMc.visible) Main.mergeMc.visible = false;
        }
    }

    private function onMouseMove(e:MouseEvent):void{
        if(border){
            var point:Point = new Point(e.stageX, e.stageY);
            if(side==TOP){
                for(var i:int=0;i<arr1.length;i++){
                    var p:Point = arr1[i].globalToLocal(point);
                    arr1[i].resize(TOP, p);
                }
                for(var i:int=0;i<arr2.length;i++){
                    var p:Point = arr2[i].globalToLocal(point);
                    arr2[i].resize(BOTTOM, p);
                }
            }else if(side==RIGHT){
                for(var i:int=0;i<arr1.length;i++){
                    var p:Point = arr1[i].globalToLocal(point);
                    arr1[i].resize(RIGHT, p);
                }
                for(var i:int=0;i<arr2.length;i++){
                    var p:Point = arr2[i].globalToLocal(point);
                    arr2[i].resize(LEFT, p);
                }
            }
            if(side==BOTTOM){
                for(var i:int=0;i<arr1.length;i++){
                    var p:Point = arr1[i].globalToLocal(point);
                    arr1[i].resize(BOTTOM, p);
                }
                for(var i:int=0;i<arr2.length;i++){
                    var p:Point = arr2[i].globalToLocal(point);
                    arr2[i].resize(TOP, p);
                }
            }
            if(side==LEFT){
                for(var i:int=0;i<arr1.length;i++){
                    var p:Point = arr1[i].globalToLocal(point);
                    arr1[i].resize(LEFT, p);
                }
                for(var i:int=0;i<arr2.length;i++){
                    var p:Point = arr2[i].globalToLocal(point);
                    arr2[i].resize(RIGHT, p);
                }
            }
        }
    }

    private function onMouseUp(e:MouseEvent):void{
        removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        border = null;
    }

    //拖动格子大小
    private function checkResizeGrids():void{
        for (var i:int = 0; i < gridContainer.numChildren; i++) {
            var g:Grid = gridContainer.getChildAt(i) as Grid;
            g.used = false;
            g.txt.text = '';
        }
        grid.used = true;
        grid.txt.text = 'true';
        grid.drawFlag(0xff9900);
        arr1.length = 0;
        arr1.push(grid);
        setNeighbor(grid);

        arr2.length = 0;
        var g:Grid = getFirstOppositeGrid(grid);
        if(g){
            g.used = true;
            g.txt.text = 'true';
            g.drawFlag(0x00ff99);
            arr2.push(g);
            setOpposite(g);
        }
    }

    //拖动格子，设置相邻格子
    private function setNeighbor(grid:Grid):void {
        if(side==TOP){
            for (var i:int = 0; i < gridContainer.numChildren; i++) {
                var g:Grid = gridContainer.getChildAt(i) as Grid;
//                if(!g.used && g.y==grid.y && g.x+g.masker.width+Config.GRID_GAP==grid.x){//左边
                if(!g.used && Math.abs(g.y-grid.y)<Config.GAP && Math.abs((g.x+g.masker.width+Config.GRID_GAP)-grid.x)<Config.GAP){//左边
                    g.used = true;
                    g.txt.text = 'true';
                    g.drawFlag(0xff9900);
                    arr1.push(g);
                    setNeighbor(g);
                    break;
                }
            }
            for (var i:int = 0; i < gridContainer.numChildren; i++) {
                var g:Grid = gridContainer.getChildAt(i) as Grid;
//                if(!g.used && g.y==grid.y && g.x-Config.GRID_GAP-grid.masker.width==grid.x){//右边
                if(!g.used && Math.abs(g.y-grid.y)<Config.GAP && Math.abs((g.x-Config.GRID_GAP-grid.masker.width)-grid.x)<Config.GAP){//右边
                    g.used = true;
                    g.txt.text = 'true';
                    g.drawFlag(0xff9900);
                    arr1.push(g);
                    setNeighbor(g);
                    break;
                }
            }
        }else if(side==RIGHT){
            for (var i:int = 0; i < gridContainer.numChildren; i++) {
                var g:Grid = gridContainer.getChildAt(i) as Grid;
//                if(!g.used && g.x+g.masker.width==grid.x+grid.masker.width && g.y+g.masker.height+Config.GRID_GAP==grid.y){//上边
                if(!g.used && Math.abs((g.x+g.masker.width)-(grid.x+grid.masker.width))<Config.GAP && Math.abs((g.y+g.masker.height+Config.GRID_GAP)-grid.y)<Config.GAP){//上边
                    g.used = true;
                    g.txt.text = 'true';
                    g.drawFlag(0xff9900);
                    arr1.push(g);
                    setNeighbor(g);
                    break;
                }
            }
            for (var i:int = 0; i < gridContainer.numChildren; i++) {
                var g:Grid = gridContainer.getChildAt(i) as Grid;
//                if(!g.used && g.x+g.masker.width==grid.x+grid.masker.width && g.y-Config.GRID_GAP-grid.masker.height==grid.y){//下边
                if(!g.used && Math.abs((g.x+g.masker.width)-(grid.x+grid.masker.width))<Config.GAP && Math.abs((g.y-Config.GRID_GAP-grid.masker.height)-grid.y)<Config.GAP){//下边
                    g.used = true;
                    g.txt.text = 'true';
                    g.drawFlag(0xff9900);
                    arr1.push(g);
                    setNeighbor(g);
                    break;
                }
            }
        }else if(side==BOTTOM){
            for (var i:int = 0; i < gridContainer.numChildren; i++) {
                var g:Grid = gridContainer.getChildAt(i) as Grid;
//                if(!g.used && g.y+g.masker.height==grid.y+grid.masker.height && g.x+g.masker.width+Config.GRID_GAP==grid.x){//左边
                if(!g.used && Math.abs((g.y+g.masker.height)-(grid.y+grid.masker.height))<Config.GAP && Math.abs((g.x+g.masker.width+Config.GRID_GAP)-grid.x)<Config.GAP){//左边
                    g.used = true;
                    g.txt.text = 'true';
                    g.drawFlag(0xff9900);
                    arr1.push(g);
                    setNeighbor(g);
                    break;
                }
            }
            for (var i:int = 0; i < gridContainer.numChildren; i++) {
                var g:Grid = gridContainer.getChildAt(i) as Grid;
//                if(!g.used && g.y+g.masker.height==grid.y+grid.masker.height && g.x-Config.GRID_GAP-grid.masker.width==grid.x){//右边
                if(!g.used && Math.abs((g.y+g.masker.height)-(grid.y+grid.masker.height))<Config.GAP && Math.abs((g.x-Config.GRID_GAP-grid.masker.width)-grid.x)<Config.GAP){//右边
                    g.used = true;
                    g.txt.text = 'true';
                    g.drawFlag(0xff9900);
                    arr1.push(g);
                    setNeighbor(g);
                    break;
                }
            }
        }else if(side==LEFT){
            for (var i:int = 0; i < gridContainer.numChildren; i++) {
                var g:Grid = gridContainer.getChildAt(i) as Grid;
//                if(!g.used && g.x==grid.x && g.y+g.masker.height+Config.GRID_GAP==grid.y){//上边
                if(!g.used && Math.abs(g.x-grid.x)<Config.GAP && Math.abs((g.y+g.masker.height+Config.GRID_GAP)-grid.y)<Config.GAP){//上边
                    g.used = true;
                    g.txt.text = 'true';
                    g.drawFlag(0xff9900);
                    arr1.push(g);
                    setNeighbor(g);
                    break;
                }
            }
            for (var i:int = 0; i < gridContainer.numChildren; i++) {
                var g:Grid = gridContainer.getChildAt(i) as Grid;
//                if(!g.used && g.x==grid.x && g.y-Config.GRID_GAP-grid.masker.height==grid.y){//下边
                if(!g.used && Math.abs(g.x-grid.x)<Config.GAP && Math.abs((g.y-Config.GRID_GAP-grid.masker.height)-grid.y)<Config.GAP){//下边
                    g.used = true;
                    g.txt.text = 'true';
                    g.drawFlag(0xff9900);
                    arr1.push(g);
                    setNeighbor(g);
                    break;
                }
            }
        }
    }

    //拖动格子，设置对面格子
    private function setOpposite(grid:Grid):void{
        if(side==TOP){
            for (var i:int = 0; i < gridContainer.numChildren; i++) {
                var g:Grid = gridContainer.getChildAt(i) as Grid;
//                if(!g.used && g.y+g.masker.height==grid.y+grid.masker.height && g.x+g.masker.width+Config.GRID_GAP==grid.x){//左边
                if(!g.used && Math.abs((g.y+g.masker.height)-(grid.y+grid.masker.height))<Config.GAP && Math.abs((g.x+g.masker.width+Config.GRID_GAP)-grid.x)<Config.GAP){//左边
                    g.used = true;
                    g.txt.text = 'true';
                    g.drawFlag(0x0099ff);
                    arr2.push(g);
                    setOpposite(g);
                    break;
                }
            }
            for (var i:int = 0; i < gridContainer.numChildren; i++) {
                var g:Grid = gridContainer.getChildAt(i) as Grid;
//                if(!g.used && g.y+g.masker.height==grid.y+grid.masker.height && g.x-Config.GRID_GAP-grid.masker.width==grid.x){//右边
                if(!g.used && Math.abs((g.y+g.masker.height)-(grid.y+grid.masker.height))<Config.GAP && Math.abs((g.x-Config.GRID_GAP-grid.masker.width)-grid.x)<Config.GAP){//右边
                    g.used = true;
                    g.txt.text = 'true';
                    g.drawFlag(0x0099ff);
                    arr2.push(g);
                    setOpposite(g);
                    break;
                }
            }
        }else if(side==RIGHT){
            for (var i:int = 0; i < gridContainer.numChildren; i++) {
                var g:Grid = gridContainer.getChildAt(i) as Grid;
//                if(!g.used && g.x==grid.x && g.y+g.masker.height+Config.GRID_GAP==grid.y){//上边
                if(!g.used && Math.abs(g.x-grid.x)<Config.GAP && Math.abs((g.y+g.masker.height+Config.GRID_GAP)-grid.y)<Config.GAP){//上边
                    g.used = true;
                    g.txt.text = 'true';
                    g.drawFlag(0x0099ff);
                    arr2.push(g);
                    setOpposite(g);
                    break;
                }
            }
            for (var i:int = 0; i < gridContainer.numChildren; i++) {
                var g:Grid = gridContainer.getChildAt(i) as Grid;
//                if(!g.used && g.x==grid.x && g.y-Config.GRID_GAP-grid.masker.height==grid.y){//下边
                if(!g.used && Math.abs(g.x-grid.x)<Config.GAP && Math.abs((g.y-Config.GRID_GAP-grid.masker.height)-grid.y)<Config.GAP){//下边
                    g.used = true;
                    g.txt.text = 'true';
                    g.drawFlag(0x0099ff);
                    arr2.push(g);
                    setOpposite(g);
                    break;
                }
            }
        }else if(side==BOTTOM){
            for (var i:int = 0; i < gridContainer.numChildren; i++) {
                var g:Grid = gridContainer.getChildAt(i) as Grid;
//                if(!g.used && g.y==grid.y && g.x+g.masker.width+Config.GRID_GAP==grid.x){//左边
                if(!g.used && Math.abs(g.y-grid.y)<Config.GAP && Math.abs((g.x+g.masker.width+Config.GRID_GAP)-grid.x)<Config.GAP){//左边
                    g.used = true;
                    g.txt.text = 'true';
                    g.drawFlag(0x0099ff);
                    arr2.push(g);
                    setOpposite(g);
                    break;
                }
            }
            for (var i:int = 0; i < gridContainer.numChildren; i++) {
                var g:Grid = gridContainer.getChildAt(i) as Grid;
//                if(!g.used && g.y==grid.y && g.x-Config.GRID_GAP-grid.masker.width==grid.x){//右边
                if(!g.used && Math.abs(g.y-grid.y)<Config.GAP && Math.abs((g.x-Config.GRID_GAP-grid.masker.width)-grid.x)<Config.GAP){//右边
                    g.used = true;
                    g.txt.text = 'true';
                    g.drawFlag(0x0099ff);
                    arr2.push(g);
                    setOpposite(g);
                    break;
                }
            }
        }else if(side==LEFT){
            for (var i:int = 0; i < gridContainer.numChildren; i++) {
                var g:Grid = gridContainer.getChildAt(i) as Grid;
//                if(!g.used && g.x+g.masker.width==grid.x+grid.masker.width && g.y+g.masker.height+Config.GRID_GAP==grid.y){//上边
                if(!g.used && Math.abs((g.x+g.masker.width)-(grid.x+grid.masker.width))<Config.GAP && Math.abs((g.y+g.masker.height+Config.GRID_GAP)-grid.y)<Config.GAP){//上边
                    g.used = true;
                    g.txt.text = 'true';
                    g.drawFlag(0x0099ff);
                    arr2.push(g);
                    setOpposite(g);
                    break;
                }
            }
            for (var i:int = 0; i < gridContainer.numChildren; i++) {
                var g:Grid = gridContainer.getChildAt(i) as Grid;
//                if(!g.used && g.x+g.masker.width==grid.x+grid.masker.width && g.y-Config.GRID_GAP-grid.masker.height==grid.y){//下边
                if(!g.used && Math.abs((g.x+g.masker.width)-(grid.x+grid.masker.width))<Config.GAP && Math.abs((g.y-Config.GRID_GAP-grid.masker.height)-grid.y)<Config.GAP){//下边
                    g.used = true;
                    g.txt.text = 'true';
                    g.drawFlag(0x0099ff);
                    arr2.push(g);
                    setOpposite(g);
                    break;
                }
            }
        }
    }

    private function getFirstOppositeGrid(grid:Grid):Grid{
        var result:Grid;
        var min:int=0, idx:int=-1;
        if(side==TOP){
            for (var i:int = 0; i < gridContainer.numChildren; i++) {
                var g:Grid = gridContainer.getChildAt(i) as Grid;
//                if (g.y + g.masker.height + Config.GRID_GAP == grid.y) {
                if (Math.abs((g.y + g.masker.height + Config.GRID_GAP) - grid.y) < Config.GAP) {
                    var dis:int = Math.abs(g.x-grid.x);
                    if(i==0 || dis<=min){
                        min = dis;
                        idx = i;
                    }
                }
            }
        }else if(side==RIGHT){
            for (var i:int = 0; i < gridContainer.numChildren; i++) {
                var g:Grid = gridContainer.getChildAt(i) as Grid;
//                if (g.x - Config.GRID_GAP - grid.masker.width == grid.x) {
                if (Math.abs((g.x - Config.GRID_GAP - grid.masker.width) - grid.x) < Config.GAP) {
                    var dis:int = Math.abs(g.y-grid.y);
                    if(i==0 || dis<=min){
                        min = dis;
                        idx = i;
                    }
                }
            }
        }else if(side==BOTTOM){
            for (var i:int = 0; i < gridContainer.numChildren; i++) {
                var g:Grid = gridContainer.getChildAt(i) as Grid;
//                if (g.y - Config.GRID_GAP - grid.masker.height  == grid.y) {
                if (Math.abs((g.y - Config.GRID_GAP - grid.masker.height) - grid.y) < Config.GAP) {
                    var dis:int = Math.abs(g.x-grid.x);
                    if(i==0 || dis<=min){
                        min = dis;
                        idx = i;
                    }
                }
            }
        }else if(side==LEFT){
            for (var i:int = 0; i < gridContainer.numChildren; i++) {
                var g:Grid = gridContainer.getChildAt(i) as Grid;
//                if (g.x + g.masker.width + Config.GRID_GAP == grid.x) {
                if (Math.abs((g.x + g.masker.width + Config.GRID_GAP) - grid.x) < Config.GAP) {
                    var dis:int = Math.abs(g.y-grid.y);
                    if(i==0 || dis<=min){
                        min = dis;
                        idx = i;
                    }
                }
            }
        }

        if(idx>=0){
            result = gridContainer.getChildAt(idx) as Grid;
        }
        return result;
    }

    public function setGrid(arr:Array, isMerge:Boolean=false):void{
        if(this.grid){
            this.grid.selected = false;
            this.grid = null;
        }
        if(this.layer){
            this.layer.selected = false;
            this.layer = null;
        }
        var a:Array = [];
        for(var i:int=0,n=gridContainer.numChildren;i<n;i++){
            var g = gridContainer.removeChildAt(0);
            if(isMerge && g.id!=0 && g.small!='' && g.big!=''){
                var mc:MovieClip = new MovieClip();
                mc.id = g.id;
                mc.small = g.small;
                mc.big = g.big;
                mc.brand = g.brand;
                mc.description = g.description;
                mc.link = g.link;
                mc.linkType = g.linkType;
                mc.isLocal = g.isLocal;
                a.push(mc);
            }
            g.dispose();
            g = null;
        }
        for(var i:int=0;i<arr.length;i++){
            var gg:Grid = new Grid(arr[i]);
            gridContainer.addChild(gg);
            if(isMerge && a[i] && a[i].id!='0' && a[i].small!='' && a[i].big!=''){
                gg.loadContent(a[i]);
            }
        }
        relate();
    }

    public function setLayer(arr:Array):void{
        if(this.grid){
            this.grid.selected = false;
            this.grid = null;
        }
        if(this.layer){
            this.layer.selected = false;
            this.layer = null;
        }
        for(var i:int=0,n=layerContainer.numChildren;i<n;i++){
            var o = layerContainer.removeChildAt(0);
            o.dispose();
            o = null;
        }
        for(var i:int=0;i<arr.length;i++){
            layerContainer.addChild(new Layer(arr[i]));
        }
    }

    public function thumbHitTest(thumb:MovieClip, type:String){
        var isHit:Boolean;
        var g:Grid;
        var l:Layer;
        if(type==TYPE_GRID){
            for (var i:int=0; i<gridContainer.numChildren; i++){
                g = gridContainer.getChildAt(i) as Grid;
                isHit = g.masker.hitTestPoint(thumb.x, thumb.y);
                if(isHit){
                    break;
                }
            }
            if(isHit){
                var obj = {
                    id : g.id,
                    small : g.small,
                    big : g.big,
                    brand : g.brand,
                    description : g.description,
                    link : g.link,
                    linkType : g.linkType,
                    isLocal : g.isLocal
                };
                g.loadContent(thumb);
                if(thumb.action=='swap'){
                    if(obj.id!='0' && obj.small!='' && obj.big!=''){
                        thumb.id = obj.id;
                        thumb.small = obj.small;
                        thumb.big = obj.big;
                        thumb.description = obj.description;
                        thumb.link = obj.link;
                        thumb.linkType = obj.linkType;
                        thumb.isLocal = obj.isLocal;
                        setTimeout(function () {
                            grid.loadContent(thumb);
                        }, 500);
                    }else{
                        grid.reset();
                    }
                }
                if(this.layer){
                    this.layer.selected = false;
                    this.layer = null;
                }
                dispatchEvent(new CanvasEvent(CanvasEvent.GRID_SELECTED, 1));
            }
        }else if(type==TYPE_LAYER){
            isHit = layerContainer.hitTestPoint(thumb.x, thumb.y);
            if(isHit){
                var p:Point = layerContainer.globalToLocal(new Point(thumb.x, thumb.y));

                if(thumb.photoWidth>Config.LAYOUT_WIDTH || thumb.photoHeight>Config.LAYOUT_HEIGHT){
                    var rw:Number = thumb.photoWidth / Config.LAYOUT_WIDTH;
                    var rh:Number = thumb.photoHeight / Config.LAYOUT_HEIGHT;
                    var ratio = (rw>rh) ? rw : rh;
                    thumb.photoWidth = thumb.photoWidth/ratio;
                    thumb.photoHeight = thumb.photoHeight/ratio;
                }

                var data = {
                    x:p.x-thumb.photoWidth/2, y:p.y-thumb.photoHeight/2, width:thumb.photoWidth, height:thumb.photoHeight,
                    photo:{id:thumb.id, small:thumb.small, big:thumb.big, x:thumb.photoWidth/2, y:thumb.photoHeight/2, width:thumb.photoWidth, height:thumb.photoHeight, scale:1, rotation:0, brand:thumb.brand, description:thumb.description, link:thumb.link, linkType:thumb.linkType, rank:0}
                };
                trace('layer thumb', thumb.photoWidth, thumb.photoHeight);
                l = new Layer(data);
                l.addEventListener(CanvasEvent.LAYER_SCALE, onLayerScale);
                layerContainer.addChild(l);
                if(this.grid){
                    this.grid.selected = false;
                    this.grid = null;
                }
                if(this.layer){
                    this.layer.selected = false;
                }
                l.selected = true;
                this.layer = l;
                dispatchEvent(new CanvasEvent(CanvasEvent.LAYER_SELECTED, {scale:1, dragable:false}));
            }
        }
    }
    //合并格子，监测关联项
    private function relate():void{
        for (var i:int=0; i<gridContainer.numChildren; i++){
            var grid:Grid = gridContainer.getChildAt(i) as Grid;
            grid.top.length = grid.right.length = grid.bottom.length = grid.left.length = 0;
        }
        for (var i:int=0; i<gridContainer.numChildren; i++){
            var grid:Grid = gridContainer.getChildAt(i) as Grid;
            for(var j=0; j<gridContainer.numChildren; j++){
                var g:Grid = gridContainer.getChildAt(j) as Grid;
//                trace(grid.data.id, g.data.id, grid.data==g.data);
                if(grid.data!=g.data){
                    if(Math.abs(grid.data.y-(g.data.y+g.data.height+Config.GRID_GAP))<Config.GAP && Math.abs(grid.data.x-g.data.x)<Config.GAP && Math.abs(grid.data.width-g.data.width)<Config.GAP){
                        grid.top.push(g);
                    }
                    if(Math.abs(grid.data.x-(g.data.x-grid.data.width-Config.GRID_GAP))<Config.GAP && Math.abs(grid.data.y-g.data.y)<Config.GAP && Math.abs(grid.data.height-g.data.height)<Config.GAP){
                        grid.right.push(g);
                    }
                    if(Math.abs(grid.data.y-(g.data.y-grid.data.height-Config.GRID_GAP))<Config.GAP && Math.abs(grid.data.x-g.data.x)<Config.GAP && Math.abs(grid.data.width-g.data.width)<Config.GAP){
                        grid.bottom.push(g);
                    }
                    if(Math.abs(grid.data.x-(g.data.x+g.data.width+Config.GRID_GAP))<Config.GAP && Math.abs(grid.data.y-g.data.y)<Config.GAP && Math.abs(grid.data.height-g.data.height)<Config.GAP){
                        grid.left.push(g);
                    }
                }
            }
        }
    }
    //合并格子
    public function merge(type:String='auto'):Boolean{
        if(type==AUTO){
            if((grid.left.length>0 || grid.right.length>0) && (grid.top.length>0 || grid.bottom.length>0)){//横纵，显示合并选项子菜单
                return false;
            }else if((grid.left.length>0 || grid.right.length>0) && grid.top.length==0 && grid.bottom.length==0){//横，直接合并
                merge(HORIZONTAL);
                return true;
            }else if(grid.left.length==0 && grid.right.length==0 && (grid.top.length>0 || grid.bottom.length>0)){//纵，直接合并
                merge(VERTICAL);
                return true;
            }
        }else if(type==HORIZONTAL){
            trace('merge', HORIZONTAL);
            for(var i:int=0;i<grid.left.length;i++){
                var g:Grid = grid.left[i] as Grid;
                var ww:Number = grid.data.width+Config.GRID_GAP;
                if(grid.right.length>0){
                    ww = (grid.data.width+Config.GRID_GAP)/2;
                }
                g.redraw(ww, 0, RIGHT);
            }
            for(var i:int=0;i<grid.right.length;i++){
                var g:Grid = grid.right[i] as Grid;
                var ww:Number = grid.data.width+Config.GRID_GAP;
                if(grid.left.length>0){
                    ww = (grid.data.width+Config.GRID_GAP)/2;
                }
                g.redraw(ww, 0, LEFT);
            }
            gridContainer.removeChild(grid);
            grid.dispose();
            grid = null;
            relate();
        }else if(type==VERTICAL){
            trace('merge', VERTICAL);
            for(var i:int=0;i<grid.top.length;i++){
                var hh:Number = (grid.bottom.length>0) ? (grid.data.height+Config.GRID_GAP)/2 : grid.data.height+Config.GRID_GAP;
                var g:Grid = grid.top[i] as Grid;
                g.redraw(0, hh, BOTTOM);
            }
            for(var i:int=0;i<grid.bottom.length;i++){
                var hh:Number = (grid.top.length>0) ? (grid.data.height+Config.GRID_GAP)/2 : grid.data.height+Config.GRID_GAP;
                var g:Grid = grid.bottom[i] as Grid;
                g.redraw(0, hh, TOP);
            }
            gridContainer.removeChild(grid);
            grid.dispose();
            grid = null;
            relate();
        }
        return true;
    }

    private function onClick(e:MouseEvent):void{
        if(e.target is Grid || e.target.parent is Grid){
            var gg:Grid = e.target as Grid || e.target.parent as Grid;
            if(!gg.selected){
                gg.selected = true;
                gg.addEventListener(CanvasEvent.GRID_SCALE, onGridScale);
                if(this.layer){
                    this.layer.selected = false;
                    this.layer = null;
                }
                if(this.grid){
                    this.grid.selected = false;
                    this.grid.removeEventListener(CanvasEvent.GRID_SCALE, onGridScale);
                }
                this.grid = gg;
                dispatchEvent(new CanvasEvent(CanvasEvent.GRID_SELECTED, gg.container.scaleX));
            }
        }
        if(e.target is Layer || e.target.parent is Layer){
            var ll:Layer = e.target as Layer || e.target.parent as Layer;
            if(!ll.selected){
                ll.selected = true;
                ll.addEventListener(CanvasEvent.LAYER_SCALE, onLayerScale);
                if(this.grid){
                    this.grid.selected = false;
                    this.grid = null;
                }
                if(this.layer){
                    this.layer.selected = false;
                    this.layer.addEventListener(CanvasEvent.LAYER_SCALE, onLayerScale);
                }
                this.layer = ll;
                layerContainer.addChild(ll);
                dispatchEvent(new CanvasEvent(CanvasEvent.LAYER_SELECTED, {scale:layer.container.scaleX, dragable:layer.layerDragable}));
            }
        }
    }

    private function onGridScale(e:CanvasEvent):void{
        trace(e.data)
        dispatchEvent(new CanvasEvent(CanvasEvent.GRID_SCALE, e.data));
    }

    private function onLayerScale(e:CanvasEvent):void{
        trace(e.data)
        dispatchEvent(new CanvasEvent(CanvasEvent.LAYER_SCALE, e.data));
    }

    private function onAddedToStage(e:Event):void{

        this.graphics.beginFill(0xffffff);
        this.graphics.drawRect(-Config.LAYOUT_WIDTH/2, -Config.LAYOUT_HEIGHT/2, Config.LAYOUT_WIDTH, Config.LAYOUT_HEIGHT);
        this.graphics.endFill();

        gridContainer = new Sprite();
        gridContainer.x = -Config.LAYOUT_WIDTH/2;
        gridContainer.y = -Config.LAYOUT_HEIGHT/2;
        addChild(gridContainer);

        layerContainer = new Sprite();
        layerContainer.graphics.beginFill(0xffffff, 0.01);
        layerContainer.graphics.drawRect(-Config.LAYOUT_WIDTH/2, -Config.LAYOUT_HEIGHT/2, Config.LAYOUT_WIDTH, Config.LAYOUT_HEIGHT);
        layerContainer.graphics.endFill();
        layerContainer.mouseEnabled = false;
        layerContainer.mouseChildren = true;
        addChild(layerContainer);

        onResize(null);

        stage.addEventListener(Event.RESIZE, onResize);
    }

    private function onResize(e:Event):void{

        h = stage.stageHeight - Config.TOP_BAR_HEIGHT - Config.GAP - Config.SOURCE_LIST_HEIGHT - Config.GAP;
        w = h*Config.LAYOUT_WIDTH/Config.LAYOUT_HEIGHT;
        s = w/Config.LAYOUT_WIDTH;

        this.scaleX = this.scaleY = s;

        this.x = Config.ACCORDION_WIDTH + Config.GAP + (stage.stageWidth - Config.ACCORDION_WIDTH - this.width)/2 + this.width/2;
        this.y = Config.TOP_BAR_HEIGHT + (stage.stageHeight-Config.TOP_BAR_HEIGHT-Config.SOURCE_LIST_HEIGHT)/2;

        var vx:int = this.x-this.width/2;
        var vy:int = this.y-this.height/2;
        var vw:int = this.width;
        var vh:int = this.height;
        DataManager.viewRect = new Rectangle(vx, vy, vw, vh);

        dispatchEvent(new CanvasEvent(CanvasEvent.SCALE, s));

    }

}
}
