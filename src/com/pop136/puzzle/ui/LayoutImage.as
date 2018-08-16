package com.pop136.puzzle.ui {
import com.pop136.puzzle.Config;
import com.pop136.puzzle.event.LayoutImageEvent;
import com.pop136.puzzle.event.Messager;
import com.pop136.puzzle.util.ArrayUtil;

import flash.display.Loader;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.events.Event;
import flash.net.URLRequest;

public class LayoutImage extends Sprite {

    private var data;
    private var gridIndex:int = 0;
    private var layerIndex:int = 0;
    private var messager:Messager = Messager.getInstance();

    public function LayoutImage() {

    }

    public function draw(data){

        removeChildren();
        gridIndex = layerIndex = 0;
        this.data = data;
        createGrid(data.grids[gridIndex]);

    }

    private function createGrid(obj:Object){

        var masker:Shape = new Shape();
        masker.graphics.beginFill(0xffffff);
        masker.graphics.drawRect(0, 0, obj.width, obj.height);
        masker.graphics.endFill();

        var container:Sprite = new Sprite();
        container.x = obj.photo.x;
        container.y = obj.photo.y;
        container.scaleX = container.scaleY = obj.photo.scale;
        container.rotation = obj.photo.rotation;

        var grid:Sprite = new Sprite();
        grid.x = obj.x;
        grid.y = obj.y;
        grid.graphics.beginFill(0xffffff);
        grid.graphics.drawRect(0, 0, obj.width, obj.height);
        grid.graphics.endFill();

        grid.addChild(container);
        grid.addChild(masker);
        grid.mask = masker;
        addChild(grid);

        if(obj.photo && obj.photo.big){
            var ldr:Loader = new Loader();
            ldr.load(new URLRequest(obj.photo.big));
            ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:Event) {
                var bitmap:Bitmap = e.target.content as Bitmap;
                bitmap.x = -bitmap.width/2;
                bitmap.y = -bitmap.height/2;
                container.addChild(bitmap);

                if(obj.photo.rotationX==-180){
                    bitmap.rotationX = obj.photo.rotationX;
                    bitmap.y = bitmap.height/2;
                }
                if(obj.photo.rotationY==-180){
                    bitmap.rotationY = obj.photo.rotationY;
                    bitmap.x = bitmap.width/2;
                }

                gridIndex++;
                if(gridIndex<data.grids.length){
                    createGrid(data.grids[gridIndex]);
                }else{
                    if(data.layers.length>0){
                        createLayer(data.layers[layerIndex]);
                    }else{
                        messager.dispatchEvent(new LayoutImageEvent(LayoutImageEvent.DRAW_COMPLETE));
                    }
                }
            });
        }else{
            gridIndex++;
            if(gridIndex<data.grids.length){
                createGrid(data.grids[gridIndex]);
            }else{
                if(data.layers.length>0){
                    createLayer(data.layers[layerIndex]);
                }else{
                    messager.dispatchEvent(new LayoutImageEvent(LayoutImageEvent.DRAW_COMPLETE));
                }
            }
        }

    }

    private function createLayer(obj:Object){
        trace(JSON.stringify(obj));
        var masker:Shape = new Shape();
        masker.graphics.beginFill(0xffffff);
        masker.graphics.drawRect(0, 0, obj.width, obj.height);
        masker.graphics.endFill();

        var container:Sprite = new Sprite();
        container.x = obj.photo.x;
        container.y = obj.photo.y;
        container.scaleX = container.scaleY = obj.photo.scale;
        container.rotation = obj.photo.rotation;

        var layer:Sprite = new Sprite();
        layer.x = obj.x+Config.LAYOUT_WIDTH/2;
        layer.y = obj.y+Config.LAYOUT_HEIGHT/2;
        layer.graphics.beginFill(0xffffff, 0);
        layer.graphics.drawRect(0, 0, obj.width, obj.height);
        layer.graphics.endFill();

        layer.addChild(container);
        layer.addChild(masker);
        layer.mask = masker;
        addChild(layer);

        if(obj.photo && obj.photo.big){
            var ldr:Loader = new Loader();
            ldr.load(new URLRequest(obj.photo.big));
            ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:Event) {
                var bitmap:Bitmap = e.target.content as Bitmap;
                bitmap.x = -bitmap.width/2;
                bitmap.y = -bitmap.height/2;
                container.addChild(bitmap);

                if(obj.photo.rotationX==-180){
                    bitmap.rotationX = -180;
                    bitmap.y = bitmap.height/2;
                }
                if(obj.photo.rotationY==-180){
                    bitmap.rotationY = -180;
                    bitmap.x = bitmap.width/2;
                }

                layerIndex++;
                if(layerIndex<data.layers.length){
                    createLayer(data.layers[layerIndex]);
                }else{
                    messager.dispatchEvent(new LayoutImageEvent(LayoutImageEvent.DRAW_COMPLETE));
                }
            });
        }else{
            layerIndex++;
            if(layerIndex<data.layers.length){
                createLayer(data.layers[layerIndex]);
            }else{
                messager.dispatchEvent(new LayoutImageEvent(LayoutImageEvent.DRAW_COMPLETE));
            }
        }

    }
}
}
