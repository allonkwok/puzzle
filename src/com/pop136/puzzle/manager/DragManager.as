package com.pop136.puzzle.manager {
import com.pop136.puzzle.ui.Canvas;
import com.pop136.puzzle.ui.LayerItem;
import com.pop136.puzzle.ui.LayerList;
import com.pop136.puzzle.ui.SourceList;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.display.Stage;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.ui.Mouse;
import flash.utils.setTimeout;

import ui.BorderCurMc;
import ui.DragCurMc;

public class DragManager {

    public static var dragCurMc:DragCurMc;
    public static var borderCurMc:BorderCurMc;
    public static var thumb:MovieClip;

    private static var stage:Stage;
    private static var canvas:Canvas;
    private static var sourceList:SourceList;
    private static var layerList:LayerList;
    private static var type:String;

    public static const DRAG:String = 'drag';
    public static const BORDER:String = 'border';
    public static const NATIVE:String = 'native';

    public static function init(stage:Stage, canvas:Canvas, sourceList:SourceList, layerList:LayerList) {
        DragManager.stage = stage;
        DragManager.canvas = canvas;
        DragManager.sourceList = sourceList;
        DragManager.layerList = layerList;

        borderCurMc = new BorderCurMc();
        borderCurMc.visible = false;
        borderCurMc.mouseEnabled = false;
        stage.addChild(borderCurMc);

        dragCurMc = new DragCurMc();
        dragCurMc.visible = false;
        dragCurMc.mouseEnabled = false;
        stage.addChild(dragCurMc);

        thumb = new MovieClip();
        thumb.alpha = .5;
        thumb.visible = false;
        thumb.id = '';
        thumb.small = '';
        thumb.big = '';
        thumb.brand = '';
        thumb.description = '';
        thumb.link = '';
        thumb.linkType = '';
        thumb.photoWidth = 0;
        thumb.photoHeight = 0;

        stage.addChild(thumb);

        stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
    }

    public static function setMouse(style:String, x:int=0, y:int=0, rotation:int=0){
        if(style==DRAG){
            Mouse.hide();
            dragCurMc.visible = true;
            dragCurMc.x = x;
            dragCurMc.y = y;
        }else if(style==BORDER){
            Mouse.hide();
            borderCurMc.visible = true;
            borderCurMc.x = x;
            borderCurMc.y = y;
            borderCurMc.rotation = rotation;
        }else if(style==NATIVE){
            borderCurMc.visible = false;
            dragCurMc.visible = false;
            Mouse.show();
        }else{
            if(dragCurMc.visible){
                dragCurMc.x = x;
                dragCurMc.y = y;
            }else if(borderCurMc.visible){
                borderCurMc.x = x;
                borderCurMc.y = y;
            }
        }
    }

    public static function showThumbByGrid(){
        type = Canvas.TYPE_GRID;
        stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        var matrix:Matrix = new Matrix();
        matrix.scale(0.5, 0.5);
        var bmd:BitmapData = new BitmapData(80, 110, false);
        bmd.draw(canvas.grid, matrix);
        var bmp:Bitmap = new Bitmap(bmd,'auto',true);
        bmp.x = -bmp.width/2;
        bmp.y = -bmp.height/2;
        thumb.removeChildren();
        thumb.visible = true;
        thumb.id = canvas.grid.id;
        thumb.small = canvas.grid.small;
        thumb.big = canvas.grid.big;
        thumb.brand = '';
        thumb.description = '';
        thumb.link = '';
        thumb.linkType = '';
        thumb.photoWidth = 0;
        thumb.photoHeight = 0;
        thumb.x = stage.mouseX;
        thumb.y = stage.mouseY;
        thumb.action = 'swap';
        thumb.addChild(bmp);
    }

    private static function onMouseDown(e:MouseEvent):void{
        stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        if(e.target && e.target.name && e.target.name.indexOf('sourcePhoto')>=0){
            type = Canvas.TYPE_GRID;
            var i:int = e.target.name.split('_')[1];
            var matrix:Matrix = new Matrix();
            matrix.scale(0.5, 0.5);
            var bmd:BitmapData = new BitmapData(80, 110, false);
            bmd.draw(e.target.container, matrix);
            var bmp:Bitmap = new Bitmap(bmd,'auto',true);
            bmp.x = -bmp.width/2;
            bmp.y = -bmp.height/2;
            thumb.removeChildren();
            thumb.visible = true;
            thumb.id = sourceList.data[i].id;
            thumb.small = sourceList.data[i].small;
            thumb.big = sourceList.data[i].big;
            thumb.brand = sourceList.data[i].brand;
            thumb.description = '';
            thumb.link = '';
            thumb.linkType = '';
            thumb.photoWidth = 0;
            thumb.photoHeight = 0;
            thumb.x = e.stageX;
            thumb.y = e.stageY;
            thumb.action = null;
            setTimeout(function () {
                thumb.addChild(bmp);
            }, 500);
        }
        if(e.target is LayerItem){
            type = Canvas.TYPE_LAYER;
            trace('layerItem click')
            var bmd:BitmapData = new BitmapData(220, 110, true);
            bmd.draw(e.target.mc.container);
            var bmp:Bitmap = new Bitmap(bmd, 'auto', false);
            bmp.x = -bmp.width/2;
            bmp.y = -bmp.height/2;
            thumb.removeChildren();
            thumb.visible = true;
            thumb.id = e.target.data.id;
            thumb.small = e.target.data.small;
            thumb.big = e.target.data.big;
            thumb.brand = e.target.data.brand;
            thumb.description = e.target.data.description;
            thumb.link = e.target.data.link;
            thumb.linkType = e.target.data.linkType;
            thumb.photoWidth = e.target.photoWidth;
            thumb.photoHeight = e.target.photoHeight;
            thumb.action = null;
            thumb.x = e.stageX;
            thumb.y = e.stageY;
            thumb.addChild(bmp);
        }
    }

    private static function onMouseMove(e:MouseEvent):void{
        if(thumb && thumb.visible){
            thumb.x = e.stageX;
            thumb.y = e.stageY;
        }
    }

    private static function onMouseUp(e:MouseEvent):void{
        if(thumb && thumb.visible){
            canvas.thumbHitTest(thumb, type);
            thumb.removeChildren();
            thumb.visible = false;
        }
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
    }

}
}
