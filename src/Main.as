package {

import com.adobe.images.JPGEncoder;
import com.adobe.images.PNGEncoder;
import com.pop136.puzzle.Config;
import com.pop136.puzzle.event.CanvasControlEvent;
import com.pop136.puzzle.event.CanvasEvent;
import com.pop136.puzzle.event.LayoutImageEvent;
import com.pop136.puzzle.event.Messager;
import com.pop136.puzzle.event.OperationEvent;
import com.pop136.puzzle.event.PhotoControlEvent;
import com.pop136.puzzle.event.ServiceEvent;
import com.pop136.puzzle.event.TemplateListEvent;
import com.pop136.puzzle.event.TopBarEvent;
import com.pop136.puzzle.manager.DataManager;
import com.pop136.puzzle.manager.DataManager;
import com.pop136.puzzle.manager.DragManager;
import com.pop136.puzzle.manager.PopupManager;
import com.pop136.puzzle.manager.ServiceManager;
import com.pop136.puzzle.ui.Accordion;
import com.pop136.puzzle.ui.Canvas;
import com.pop136.puzzle.ui.CanvasControl;
import com.pop136.puzzle.ui.LayerList;
import com.pop136.puzzle.ui.LayoutImage;
import com.pop136.puzzle.ui.PhotoControl;
import com.pop136.puzzle.ui.SourceList;
import com.pop136.puzzle.ui.TemplateList;
import com.pop136.puzzle.ui.TopBar;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.JPEGEncoderOptions;
import flash.display.PNGEncoderOptions;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageDisplayState;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLVariables;
import flash.text.TextField;
import flash.utils.ByteArray;

import ui.LayoutWordMc;
import ui.MergeMc;

[SWF(width="1300", height="650", backgroundColor="0xe1e1e1", frameRate="25")]
public class Main extends Sprite {

    private var debugStr:String;
    private static var debugTxt:TextField;
    private var isDebug:Boolean = false;
    private var topBar:TopBar;
    private var accordion:Accordion;
    private var photoControl:PhotoControl;
    private var canvasControl:CanvasControl;
    private var sourceList:SourceList;
    private var canvas:Canvas;
    public static var mergeMc:MergeMc;
    private var layerList:LayerList;
    private var layoutImage:LayoutImage;

    private var layoutData:String;

    private var messager:Messager = Messager.getInstance();

    public function Main() {

        if(ExternalInterface.available){
            var search:String = ExternalInterface.call("function getURL(){return window.location.search;}").split("?")[1];
            var vars:URLVariables = new URLVariables(search);
            ServiceManager.site = parseInt(vars.site) || 1;
            isDebug = Boolean(vars.isDebug) || false;
        }else{
            ServiceManager.site = 1;
            isDebug = false;
        }


        canvasControl = new CanvasControl();

        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);

        messager.addEventListener(TopBarEvent.SELECT, onTabSelect);
        messager.addEventListener(TopBarEvent.SAVE, onSave);
        messager.addEventListener(TopBarEvent.SUBMIT, onSubmit);
        messager.addEventListener(ServiceEvent.GET_TEMPLATE_COMPLETE, onGetTemplateComplete);
        messager.addEventListener(ServiceEvent.GET_LAYOUT_COMPLETE, onGetLayoutComplete);
        messager.addEventListener(ServiceEvent.SET_FULL_SCREEN, setFullScreen);
        messager.addEventListener(ServiceEvent.SAVE_LAYOUT_IMAGE_COMPLETE, onSaveLayoutImageComplete);
        messager.addEventListener(LayoutImageEvent.DRAW_COMPLETE, onDrawComplete);
        messager.addEventListener(OperationEvent.APPLY, onApply);

//        var loader:URLLoader = new URLLoader(new URLRequest('layout.json'));
//        loader.addEventListener(Event.COMPLETE, function (e:Event) {
//            var event:ServiceEvent = new ServiceEvent(ServiceEvent.GET_LAYOUT_COMPLETE, e.target.data);
//            onGetLayoutComplete(event);
//        })

        var event:ServiceEvent = new ServiceEvent(ServiceEvent.GET_LAYOUT_COMPLETE);
        onGetLayoutComplete(event);

    }

    private function onApply(e:OperationEvent){
        mergeMc.subMc.visible = false;
        mergeMc.visible = false;
        photoControl.resetDragBtn();
    }

    private function setFullScreen(e:ServiceEvent):void{
        Main.debug(stage.displayState);
        if(stage.displayState==StageDisplayState.NORMAL){
            Main.debug('stage.displayState = StageDisplayState.FULL_SCREEN');
            stage.displayState = StageDisplayState.FULL_SCREEN;
        }else{
            stage.displayState = StageDisplayState.NORMAL;
        }
    }

    private function onGetLayoutComplete(e:ServiceEvent):void{
        layoutData = e.data;
        ServiceManager.getTemplate();
    }

    private function onTabSelect(e:TopBarEvent):void{
        var tmpid:int = int(e.data);

        trace("onTabSelect", tmpid, DataManager.layoutTmpId);

        if(tmpid!=DataManager.layoutTmpId){

            var prevLayout = DataManager.getLayout(DataManager.layoutTmpId);

            if(prevLayout){
                prevLayout.grids = canvas.getGrids();
                prevLayout.layers = canvas.getLayers();
                prevLayout.gridSources = sourceList.getSources();
                prevLayout.layerSources = layerList.getSources();
                prevLayout.title = accordion.getTitle();
                prevLayout.description = accordion.getDescription();

                trace("prev layout:",JSON.stringify(prevLayout));
            }

            DataManager.layoutTmpId = tmpid;

            var currentLayout = DataManager.getLayout(DataManager.layoutTmpId);

            trace("current layout:",JSON.stringify(currentLayout));
            canvas.setGrid(currentLayout.grids);
            canvas.setLayer(currentLayout.layers);
            accordion.setLayoutWord(currentLayout.title, currentLayout.description);
            layerList.setSources(currentLayout.layerSources);
            mergeMc.visible = false;
            mergeMc.subMc.visible = false;

        }
    }

    private function onSave(e:TopBarEvent):void{
        if(DataManager.layouts.length>0){
            var layout = DataManager.getLayout(DataManager.layoutTmpId);
            layout.grids = canvas.getGrids();
            layout.layers = canvas.getLayers();
            layout.gridSources = sourceList.getSources();
            layout.layerSources = layerList.getSources();
            layout.title = accordion.getTitle();
            layout.description = accordion.getDescription();
            layout.id = ServiceManager.saveSingleLayout(JSON.stringify(layout));
            PopupManager.showSaveDialog("当前设计版面已保存！");
        }else{
            PopupManager.showSaveDialog("没有设计版面，请先创建一个设计版面！");
        }
    }

//    private function onSave(e:TopBarEvent):void{
//        if(DataManager.layouts.length>0){
//            var matrix:Matrix = new Matrix();
//            matrix.tx = Config.LAYOUT_WIDTH/2;
//            matrix.ty = Config.LAYOUT_HEIGHT/2;
//            var bmd:BitmapData = new BitmapData(Config.LAYOUT_WIDTH, Config.LAYOUT_HEIGHT);
//            bmd.draw(canvas, matrix);
//            var encoder:JPGEncoder = new JPGEncoder();
//            var bytes:ByteArray = encoder.encode(bmd);
//            ServiceManager.saveLayoutImage(bytes);
//        }else{
//            PopupManager.showSaveDialog("没有设计版面，请先创建一个设计版面！");
//        }
//    }
//
//    private function onSaveCanvasComplete(e:ServiceEvent):void{
//        var layout = DataManager.getLayout(DataManager.layoutTmpId);
//        layout.grids = canvas.getGrids();
//        layout.layers = canvas.getLayers();
//        layout.gridSources = sourceList.getSources();
//        layout.layerSources = layerList.getSources();
//        layout.title = accordion.getTitle();
//        layout.description = accordion.getDescription();
//        layout.id = ServiceManager.saveSingleLayout(JSON.stringify(layout));
//        trace(e.data.toString());
//        var o = JSON.parse(e.data.toString());
//        layout.photo = {id:o.data.id, url:o.data.photo};
//        PopupManager.showSaveDialog("当前设计版面已保存！");
//    }

//    private function onSubmit(e:TopBarEvent):void{
//        if(DataManager.layouts.length>0){
//            //保存当前版面
//            var layout = DataManager.getLayout(DataManager.layoutTmpId);
//            layout.grids = canvas.getGrids();
//            layout.layers = canvas.getLayers();
//            layout.gridSources = sourceList.getSources();
//            layout.layerSources = layerList.getSources();
//            layout.title = accordion.getTitle();
//            layout.description = accordion.getDescription();
//            //使用最终的SourceList资源
//            for(var i:int=0;i<DataManager.layouts.length;i++){
//                DataManager.layouts[i].gridSources = sourceList.getSources();
//            }
//            //提交所有版面
//            var layoutsJson:String = JSON.stringify(DataManager.layouts);
//            ServiceManager.saveLayout(layoutsJson);
//            PopupManager.showSaveDialog("所有版面信息已提交！");
//        }else{
//            PopupManager.showSaveDialog("没有设计版面，请先创建一个设计版面！");
//        }
//    }

    private var layoutIndex:int = 0;

    private function onSubmit(e:TopBarEvent):void{
        if(DataManager.layouts.length>0){
            //保存当前版面
            var layout = DataManager.getLayout(DataManager.layoutTmpId);
            layout.grids = canvas.getGrids();
            layout.layers = canvas.getLayers();
            layout.gridSources = sourceList.getSources();
            layout.layerSources = layerList.getSources();
            layout.title = accordion.getTitle();
            layout.description = accordion.getDescription();
            //使用最终的SourceList资源
            for(var i:int=0;i<DataManager.layouts.length;i++){
                DataManager.layouts[i].gridSources = sourceList.getSources();
            }

            layoutIndex = 0;

            var isValid = true;
            for (var i:int = 0; i < layout.grids.length; i++){
                var grid = layout.grids[i];
                if(!grid.photo.big || grid.photo.big==''){
//                    isValid = false;
//                    PopupManager.showSaveDialog("格子为空，或图片未全部上传！");
                    trace(JSON.stringify(layout));
                    break;
                }
            }

            if(isValid){
                PopupManager.showSaveDialog("正在提交第 " + (layoutIndex+1) + " 张设计", false);
                var data = DataManager.layouts[layoutIndex];
                layoutImage.draw(data);
            }

        }else{
            PopupManager.showSaveDialog("没有设计版面，请先创建一个设计版面！");
        }
    }

    private function onDrawComplete(e:LayoutImageEvent){
//        var matrix:Matrix = new Matrix();
//        matrix.tx = Config.LAYOUT_WIDTH/2;
//        matrix.ty = Config.LAYOUT_HEIGHT/2;
        var bmd:BitmapData = new BitmapData(Config.LAYOUT_WIDTH, Config.LAYOUT_HEIGHT);
//        bmd.draw(layoutImage, matrix);
        bmd.draw(layoutImage);
        var bytes:ByteArray = bmd.encode(new Rectangle(0,0,bmd.width,bmd.height), new JPEGEncoderOptions());
//        var encoder:JPGEncoder = new JPGEncoder(80);
//        var bytes:ByteArray = encoder.encode(bmd);
//        var bytes:ByteArray = PNGEncoder.encode(bmd);
        ServiceManager.saveLayoutImage(bytes);
    }

    private function onSaveLayoutImageComplete(e:ServiceEvent){
        var o = JSON.parse(e.data.toString());
        DataManager.layouts[layoutIndex].photo = {id:o.data.id, url:o.data.photo};
        layoutIndex++;
        if(layoutIndex < DataManager.layouts.length){
            PopupManager.showSaveDialog("正在提交第 " + (layoutIndex+1) + " 张设计", false);
            var data = DataManager.layouts[layoutIndex];
            layoutImage.draw(data);
        }else{
            //提交所有版面
            var layoutsJson:String = JSON.stringify(DataManager.layouts);
            ServiceManager.saveLayout(layoutsJson);
            PopupManager.showSaveDialog("所有版面信息已提交！");
        }

    }

    public static function debug(str:String){
        debugTxt.htmlText += str+"<br>";
    }

    private function onAddedToStage(e:Event):void{

        ServiceManager.init();

        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;

        stage.addEventListener(MouseEvent.CLICK, function(e:MouseEvent){
            trace(e.target, e.target.name);
            if(e.target.name==null){
                if(canvas.grid){
                    canvas.grid.selected = false;
                    canvas.grid = null;
                    mergeMc.visible = false;
                    mergeMc.subMc.visible = false;
                }
                if(canvas.layer){
                    canvas.layer.selected = false;
                    canvas.layer = null;
                }
                photoControl.visible = false;
            }
        });

        layoutImage = new LayoutImage();
        layoutImage.visible = false;

        canvas = new Canvas();
        canvas.x = Config.ACCORDION_WIDTH + Config.GAP + (stage.stageWidth - Config.ACCORDION_WIDTH - canvas.width)/2 + canvas.width/2;
        canvas.y = Config.TOP_BAR_HEIGHT + (stage.stageHeight-Config.TOP_BAR_HEIGHT-Config.SOURCE_LIST_HEIGHT)/2;
        canvas.addEventListener(CanvasEvent.SCALE, onCanvasScale);
        canvas.addEventListener(CanvasEvent.GRID_SCALE, onGridScale);
        canvas.addEventListener(CanvasEvent.GRID_SELECTED, onGridSelected);
        canvas.addEventListener(CanvasEvent.LAYER_SCALE, onLayerScale);
        canvas.addEventListener(CanvasEvent.LAYER_SELECTED, onLayerSelected);
        addChild(canvas);

        mergeMc = new MergeMc();
        mergeMc.visible = false;
        mergeMc.subMc.visible = false;
        mergeMc.addEventListener(MouseEvent.CLICK, onMergeMcClick);
        addChild(mergeMc);

        topBar = new TopBar();
        addChild(topBar);

        accordion = new Accordion();
        accordion.y = topBar.height;
        addChild(accordion);

        layerList = new LayerList();
        layerList.y = 10;

        sourceList = new SourceList();
        addChild(sourceList);
        sourceList.x = accordion.width;
        sourceList.y = stage.stageHeight - sourceList.height;

        photoControl = new PhotoControl();
        photoControl.visible = false;
        photoControl.x = accordion.width + Config.GAP;
        photoControl.y = topBar.height + Config.GAP;
        photoControl.addEventListener(PhotoControlEvent.SLIDE, onPhotoControlSlide);
        photoControl.addEventListener(PhotoControlEvent.ROTATE, onPhotoControlRotate);
        photoControl.addEventListener(PhotoControlEvent.HORIZONTAL, onPhotoControlHorizontal);
        photoControl.addEventListener(PhotoControlEvent.VERTICAL, onPhotoControlVertical);
        photoControl.addEventListener(PhotoControlEvent.SELECT, onPhotoControlSelect);
        photoControl.addEventListener(PhotoControlEvent.LINK, onPhotoControlLink);
        photoControl.addEventListener(PhotoControlEvent.DRAG, onPhotoControlDrag);
        photoControl.addEventListener(PhotoControlEvent.DELETE, onPhotoControlDelete);
        addChild(photoControl);

        canvasControl.x = stage.stageWidth - canvasControl.width - Config.GAP;
        canvasControl.y = sourceList.y - canvasControl.height - Config.GAP + 30 + 120 + 5;
        canvasControl.addEventListener(CanvasControlEvent.SLIDE, onCanvasControlSlide);
        canvasControl.addEventListener(CanvasControlEvent.RESET, onCanvasControlReset);
        canvasControl.addEventListener(CanvasControlEvent.MOVE, onCanvasControlMove);
        addChild(canvasControl);

        DataManager.stageWidth = stage.stageWidth;
        DataManager.stageHeight = stage.stageHeight;

        var vx:int = canvas.x-canvas.width/2;
        var vy:int = canvas.y-canvas.height/2;
        var vw:int = canvas.width;
        var vh:int = canvas.height;
        DataManager.viewRect = new Rectangle(vx, vy, vw, vh);

        stage.addEventListener(Event.RESIZE, onResize);

        debugStr = "";
        debugTxt = new TextField();
        debugTxt.width = 300;
        debugTxt.height = 300;
        debugTxt.border = true;
        debugTxt.mouseEnabled = false;
        debugTxt.htmlText = "";
        debugTxt.multiline = true;
        if(isDebug)
            addChild(debugTxt);

        var txt:TextField = new TextField();
        txt.border = true;
        txt.text = 'v1.46';
        txt.width = 80;
        txt.height = 20;
        txt.mouseEnabled = false;
        addChild(txt);

        PopupManager.init(stage);
        DragManager.init(stage, canvas, sourceList, layerList);
    }

    private function onMergeMcClick(e:MouseEvent):void{
        if(e.target.name=='closeBtn'){
            var str = 'top:';
            for(var i=0;i<canvas.grid.top.length;i++){
                str += canvas.grid.top[i].data.id + ' ';
            }
            str += 'right:';
            for(var i=0;i<canvas.grid.right.length;i++){
                str += canvas.grid.right[i].data.id + ' ';
            }
            str += 'bottom:';
            for(var i=0;i<canvas.grid.bottom.length;i++){
                str += canvas.grid.bottom[i].data.id + ' ';
            }
            str += 'left:';
            for(var i=0;i<canvas.grid.left.length;i++){
                str += canvas.grid.left[i].data.id + ' ';
            }
            trace(str);

            if(!canvas.merge()){
                mergeMc.subMc.visible = true;
            } else {
                mergeMc.visible = false;
            }
        }else if(e.target.name=='horizontalBtn'){
            canvas.merge(Canvas.HORIZONTAL);
            mergeMc.visible = false;
        }else if(e.target.name=='verticalBtn'){
            canvas.merge(Canvas.VERTICAL);
            mergeMc.visible = false;
        }
    }

    private function onEnterFrame(e:Event):void{
        if(canvasControl){
            canvasControl.updateThumb(canvas);
        }
    }

    private function onCanvasControlMove(e:CanvasControlEvent):void{
        var p:Point = e.data as Point;
        canvas.x = Config.ACCORDION_WIDTH + Config.GAP + (stage.stageWidth - Config.ACCORDION_WIDTH - canvas.width)/2 + canvas.width/2 - p.x;
        canvas.y = Config.TOP_BAR_HEIGHT + (stage.stageHeight-Config.TOP_BAR_HEIGHT-Config.SOURCE_LIST_HEIGHT)/2 - p.y;
        setMergeMcPosition();
    }

    private function onPhotoControlRotate(e:PhotoControlEvent):void{
        if(canvas.grid && canvas.grid.container){
            var rotation = parseInt(e.data.toString());
            canvas.grid.container.rotation = rotation;
            canvas.onSaveOperation();
        }
    }

    private function onPhotoControlHorizontal(e:PhotoControlEvent):void{
        var bmp:Bitmap;
        if(canvas.grid && canvas.grid.container.numChildren>0){
            bmp = canvas.grid.container.getChildAt(0) as Bitmap;
            canvas.grid.ry = (canvas.grid.ry == 0) ? -180 : 0;
        }
        if(canvas.layer && canvas.layer.container.numChildren>0){
            bmp = canvas.layer.container.getChildAt(0) as Bitmap;
            canvas.layer.ry = (canvas.layer.ry == 0) ? -180 : 0;
        }
        if(bmp){
//            if(bmp.rotationY==0){
//                bmp.rotationY = -180;
//                bmp.x = bmp.width/2;
//            }else {
//                bmp.rotationY = 0;
//                bmp.x = -bmp.width/2;
//            }
            var matrix:Matrix = new Matrix();
            matrix.a = -1;
            matrix.tx = bmp.bitmapData.width;
            bmp.bitmapData.draw(bmp.bitmapData.clone(), matrix);
            canvas.onSaveOperation();
        }
    }

    private function onPhotoControlVertical(e:PhotoControlEvent):void{
        var bmp:Bitmap;
        if(canvas.grid && canvas.grid.container.numChildren>0){
            bmp = canvas.grid.container.getChildAt(0) as Bitmap;
            canvas.grid.rx = (canvas.grid.rx == 0) ? -180 : 0;
        }
        if(canvas.layer && canvas.layer.container.numChildren>0){
            bmp = canvas.layer.container.getChildAt(0) as Bitmap;
            canvas.layer.rx = (canvas.layer.rx == 0) ? -180 : 0;
        }
        if(bmp){
//            if(bmp.rotationX==0){
//                bmp.rotationX = -180;
//                bmp.y = bmp.height/2;
//            }else{
//                bmp.rotationX = 0;
//                bmp.y = -bmp.height/2;
//            }
            var matrix:Matrix = new Matrix();
            matrix.d = -1;
            matrix.ty = bmp.bitmapData.height;
            bmp.bitmapData.draw(bmp.bitmapData.clone(), matrix);
            canvas.onSaveOperation();
        }
    }

    private function onPhotoControlSelect(e:PhotoControlEvent):void{
        if(canvas.grid){
            canvas.grid.select();
        }
    }

    private function onPhotoControlLink(e:PhotoControlEvent):void{
        if(canvas.grid){
            PopupManager.showCommonDialog(canvas.grid.brand, canvas.grid.description, canvas.grid.linkType, canvas.grid.link);
        }
        if(canvas.layer){
            PopupManager.showCommonDialog(canvas.layer.brand, canvas.layer.description, canvas.layer.linkType, canvas.layer.link);
        }
    }

    private function onPhotoControlDrag(e:PhotoControlEvent):void{
        trace(canvas.layer);
        if(canvas.layer){
            canvas.layer.layerDragable = !canvas.layer.layerDragable;
        }
    }

    private function onPhotoControlDelete(e:PhotoControlEvent):void{
        if(canvas.grid && canvas.grid.container.numChildren>0){
            canvas.grid.reset();
            canvas.onSaveOperation();
        }
        if(canvas.layer && canvas.layer.container.numChildren>0){
            canvas.layerContainer.removeChild(canvas.layer);
            canvas.layer.dispose();
            canvas.layer = null;
            canvas.onSaveOperation();
            if(canvas.layerContainer.numChildren==0){
                photoControl.resetDragBtn();
            }
        }
    }

    private function onGridSelected(e:CanvasEvent):void{
        var n:Number = e.data as Number;
        trace('onGridSelected:', n);
        photoControl.visible = true;
        photoControl.showSelect();
        photoControl.setValue(n);
        if(canvas.gridContainer.numChildren>1){
            mergeMc.visible = true;
            mergeMc.subMc.visible = false;
            setMergeMcPosition();
        }
    }

    private function onLayerSelected(e:CanvasEvent):void{
        var n:Number = e.data.scale;
        var status:String = (e.data.dragable) ? "selected" : "default";
        trace('onLayerSelected:', n);
        photoControl.visible = true;
        photoControl.showDrag(status);
        photoControl.setValue(n);
        mergeMc.visible = false;
        mergeMc.subMc.visible = false;
    }

    private function onGridScale(e:CanvasEvent):void{
        var n:Number = e.data as Number;
        photoControl.setValue(n);
    }

    private function onLayerScale(e:CanvasEvent):void{
        var n:Number = e.data as Number;
        photoControl.setValue(n);
    }

    private function onGetTemplateComplete(e:ServiceEvent):void{

        DataManager.templates = JSON.parse(e.data.toString()).data;
        trace(e.data.toString());
        var layoutWord = new LayoutWordMc();
        layoutWord.titleTxt.text = "";
        layoutWord.descriptionTxt.text = "";
        var templateList = new TemplateList();
        templateList.x = templateList.y = 10;
        templateList.addEventListener(TemplateListEvent.CREATE_COMPLETE, function (ee:TemplateListEvent) {
            trace("accordion add content");
            accordion.addContentAt(templateList, 0);
            accordion.addContentAt(layoutWord, 1);
            accordion.addContentAt(layerList, 2);
            if(layoutData==null || layoutData==''){
                var obj = {
                    id:0,
                    tmpid:1,
                    title:"",
                    description:"",
                    grids:[],
                    gridSources:[],
                    layers:[],
                    layerSources:[],
                    action:{
                        undoArr:[],
                        redoArr:[],
                        cache:{
                            grids:[],
                            layers:[]
                        }
                    }
                };
                DataManager.layouts.push(obj);
                DataManager.layoutTmpId = 1;
            }else{
                var obj = JSON.parse(layoutData);
                obj.action = {
                    undoArr:[],
                    redoArr:[],
                    cache:{
                        grids:[],
                        layers:[]
                    }
                }
                obj.tmpid = 1;
                DataManager.layouts.push(obj);
                DataManager.layoutTmpId = 1;
                canvas.setGrid(obj.grids);
                canvas.setLayer(obj.layers);
                accordion.setLayoutWord(obj.title, obj.description);
                sourceList.setSourceList(JSON.stringify(obj.gridSources));
                topBar.tabBtn.visible = false;
                topBar.setTabName(0, obj.title);
            }
        });
        templateList.addEventListener(TemplateListEvent.CHANGE, function (ee:TemplateListEvent) {
//            canvas.container.removeChildren();
            var arr:Array = ee.data as Array;
            canvas.setGrid(arr, true);
            canvas.setLayer([]);
            trace(JSON.stringify(arr));
            trace(JSON.stringify(DataManager.templates[DataManager.templateIndex].grids));
            DataManager.getLayout(DataManager.layoutTmpId).grids = arr;
            mergeMc.visible = false;
            canvas.onSaveOperation();
        });
    }

    private function onCanvasControlSlide(e:CanvasControlEvent):void{
        canvas.scaleX = canvas.scaleY = Number(e.data);
        trace('canvas.width canvas.height:', canvas.width, canvas.height, canvas.scaleX);
        trace('canvas.w canvas.h:', canvas.w, canvas.h, canvas.s);
        setMergeMcPosition();
    }

    private function onPhotoControlSlide(e:PhotoControlEvent):void{
        if(canvas.grid && canvas.grid.container.numChildren>0){
            var n:Number = e.data as Number;
            canvas.grid.container.scaleX = canvas.grid.container.scaleY = Number(n.toFixed(2));
        }
        if(canvas.layer && canvas.layer.container.numChildren>0){
            var n:Number = e.data as Number;
            canvas.layer.container.scaleX = canvas.layer.container.scaleY = Number(n.toFixed(2));
        }
    }

    private function onCanvasControlReset(e:CanvasControlEvent):void{
        var s:Number;
        if(e.data.toString()==CanvasControl.EXACT_FIT){
            var h = stage.stageHeight - Config.TOP_BAR_HEIGHT - Config.GAP - Config.SOURCE_LIST_HEIGHT - Config.GAP;
            var w = h*Config.LAYOUT_WIDTH/Config.LAYOUT_HEIGHT;
            s = w/Config.LAYOUT_WIDTH;
        }else if(e.data.toString()==CanvasControl.NO_SCALE){
            s = 1;
        }
        canvas.scaleX = canvas.scaleY = s;
        canvas.x = Config.ACCORDION_WIDTH + Config.GAP + (stage.stageWidth - Config.ACCORDION_WIDTH - canvas.width)/2 + canvas.width/2;
        canvas.y = Config.TOP_BAR_HEIGHT + (stage.stageHeight-Config.TOP_BAR_HEIGHT-Config.SOURCE_LIST_HEIGHT)/2;
        canvasControl.setValue(s);
        setMergeMcPosition();
    }

    private function setMergeMcPosition():void{
        if(canvas.grid){
            var lx = canvas.grid.x + canvas.grid.masker.width;
            var ly = canvas.grid.y;
            var p:Point = canvas.localToGlobal(new Point(lx, ly));
            mergeMc.x = p.x-canvas.scaleX*Config.LAYOUT_WIDTH/2;
            mergeMc.y = p.y-canvas.scaleY*Config.LAYOUT_HEIGHT/2;
        }
    }

    private function onCanvasScale(e:CanvasEvent):void{
        var n:Number = Number(e.data);
        canvasControl.setValue(n);
    }

    private function onResize(e:Event):void{

        DataManager.stageWidth = stage.stageWidth;
        DataManager.stageHeight = stage.stageHeight;

        canvasControl.x = stage.stageWidth - canvasControl.width - Config.GAP;
        canvasControl.y = sourceList.y - canvasControl.height - Config.GAP + 30 + 120 + 10;

        setMergeMcPosition();
    }
}
}
