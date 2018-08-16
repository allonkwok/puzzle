package com.pop136.puzzle.manager {
import com.adobe.crypto.MD5;
import com.pop136.puzzle.Config;
import com.pop136.puzzle.event.Messager;
import com.pop136.puzzle.event.ServiceEvent;
import com.pop136.puzzle.manager.ServiceManager;

import flash.display.Stage;
import flash.display.StageDisplayState;

import flash.events.DataEvent;

import flash.events.Event;
import flash.events.ProgressEvent;
import flash.external.ExternalInterface;
import flash.net.FileReference;

import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.utils.ByteArray;

public class ServiceManager {

//    public static const SITE_URL:String = 'http://puzzle.cn/';
//    public static const GET_TEMPLATE_URL:String = SITE_URL+'get-template.php';
//    public static const SAVE_PHOTO:String = SITE_URL+'save-photo.php';
//    public static const SAVE_LAYOUT_IMAGE:String = SITE_URL+'save-layout.php';

    public static const SITE_URL:String = 'http://www.pop-fashion.com/';
    public static const GET_TEMPLATE_URL:String = SITE_URL+'puzzle/getPuzzleTemplates/';
    public static const SAVE_PHOTO:String = SITE_URL+'puzzle/uploadLocalPhoto/';
    public static const SAVE_LAYOUT_IMAGE:String = SITE_URL+'puzzle/uploadLocalPhoto/';

    private static const KEY:String = 'Pop_Puzzle';

    public static var site:int = 0;

    private static var messager:Messager = Messager.getInstance();

    public static function init(){
        if(ExternalInterface.available){
            ExternalInterface.addCallback("setSourceList", function (data:String='') {
                Main.debug('setSourceList');
                messager.dispatchEvent(new ServiceEvent(ServiceEvent.GET_SOURCE_COMPLETE, data));
            });
            ExternalInterface.addCallback("setLayout", function (data:String='') {
                Main.debug('setLayout');
                messager.dispatchEvent(new ServiceEvent(ServiceEvent.GET_LAYOUT_COMPLETE, data));
            });
            ExternalInterface.addCallback("setFullScreen", function () {
                Main.debug('setFullScreen');
                messager.dispatchEvent(new ServiceEvent(ServiceEvent.SET_FULL_SCREEN));
            });
        }
    }

    public static function getTemplate(){
        var vars:URLVariables = new URLVariables();
        vars.hash = MD5.hash(KEY+getDate());trace(KEY+getDate());trace(vars.hash);
        vars.site = site;
        var request:URLRequest = new URLRequest(GET_TEMPLATE_URL+"?rnd="+Math.random());
        request.data = vars;
        request.method = URLRequestMethod.POST;
        var loader:URLLoader = new URLLoader(request);
        loader.addEventListener(Event.COMPLETE, function (e:Event) {
           messager.dispatchEvent(new ServiceEvent(ServiceEvent.GET_TEMPLATE_COMPLETE, e.target.data));
        });
    }

    public static function savePhoto(fr:FileReference, type:String='layer'){
        var vars:URLVariables = new URLVariables();
        vars.hash = MD5.hash(KEY+getDate());
        vars.site = site;
        vars.type = type;
        var request:URLRequest = new URLRequest(SAVE_PHOTO+"?rnd="+Math.random());
        request.data = vars;
        request.method = URLRequestMethod.POST;
        fr.upload(request);
    }

    public static function saveLayoutImage(bytes:ByteArray){
        var request:URLRequest = new URLRequest(SAVE_LAYOUT_IMAGE+"?rnd="+Math.random()+"&hash="+MD5.hash(KEY+getDate())+"&site="+site);
        request.data = bytes;
        request.method = URLRequestMethod.POST;
        request.contentType = "application/octet-stream";
        var loader:URLLoader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.BINARY;
        loader.load(request);
        loader.addEventListener(Event.COMPLETE, function (e:Event) {
            messager.dispatchEvent(new ServiceEvent(ServiceEvent.SAVE_LAYOUT_IMAGE_COMPLETE, e.target.data));
        });
    }

    public static function showSource(ids:String=''){
        if(ExternalInterface.available){
            ExternalInterface.call('showSource', ids);
        }
    }

    public static function saveLayout(json:String=''){
        if(ExternalInterface.available){
            ExternalInterface.call('saveLayout', json);
        }else{
            trace(json);
        }
    }

    public static function saveSingleLayout(json:String=''):int{
        var n:int;
        if(ExternalInterface.available){
            n = ExternalInterface.call('saveSingleLayout', json);
        }
        return n;
    }

    public static function deleteLayout(id:int){
        if(ExternalInterface.available){
            ExternalInterface.call('deleteLayout', id);
        }
    }

    private static function getDate():String{
        var d:Date = new Date();
        var yearStr:String = d.fullYear.toString();
        var month:int = d.month+1;
        var monthStr = month>=10 ? month.toString() : "0"+month;
        var date:int = d.date;
        var dateStr = date>=10 ? date.toString() : "0"+date;
        var str:String = yearStr+"-"+monthStr+"-"+dateStr;
        return str;
    }

}
}
