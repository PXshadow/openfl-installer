package;

import haxe.Timer;
import lime.tools.helpers.HaxelibHelper;
import lime.tools.helpers.ProcessHelper;
import lime.ui.FileDialog;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.display.DisplayObjectContainer;
import openfl.Lib;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.ui.Keyboard;
import sys.FileSystem;
import sys.io.Process;
import systools.Dialogs;
import systools.FileUtils;

import lime.project.Haxelib;
import lime.project.Platform;
import lime.tools.helpers.PlatformHelper;
import lime.tools.helpers.PathHelper;
import openfl.events.KeyboardEvent;

/**
 * ...
 * @author 
 */
class Main extends DisplayObjectContainer
{
	var logo:Bitmap;
	var text:TextField;
	var underline:Shape;
	var list:Array<String> = ["haxe", "openfl", "lime"];
	var version:Array<String> = [];
	var path:Array<String> = [];
	//-1 = version, 0 = searching, 1 = failed, 2 = needs update
	var type:Array<Int> = [];
	var infoInt:Int = -1;
	

	public function new() 
	{
		super();
		
		logo = new Bitmap();
		logo.y = 10;
		Assets.loadBitmapData("assets/img/logo.png").onComplete(function(bmd:BitmapData)
		{
		logo.bitmapData = bmd;
		logo.x = (stage.stageWidth - logo.width) / 2;
		//set text
		text.x = logo.x;
		text.y = logo.y + logo.height + 10;
		text.height = stage.stageHeight - text.y;
		//set underline
		underline.x = logo.x - 100;
		underline.width = logo.width + 100 * 2;
		});
		addChild(logo);
		
		stage.addEventListener(Event.ENTER_FRAME, update);
		stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		
		//text display
		text = new TextField();
		text.selectable = false;
		text.mouseEnabled = false;
		text.width = stage.stageWidth;
		//text.cacheAsBitmap = true;
		text.defaultTextFormat = new TextFormat("_sans", 16, 5263440);
		refreshText();
		addChild(text);
		//underline
		underline = new Shape();
		underline.graphics.beginFill(0);
		underline.graphics.drawRect(0, 0, 1, 2);
		underline.visible = false;
		addChild(underline);
		
		//aleart
		//Lib.application.window.alert(null, null);
		//commands
		checkHaxe();
		checkOpenfl();
		checkLime();
	}
	
	public function checkHaxe()
	{
		var haxeString:String = "Haxe Compiler ";
		var returnHaxe = runProcess("haxe");
		var set = get("haxe");
		
		if (returnHaxe != null && returnHaxe.substring(0, haxeString.length) == haxeString)
		{
			version[set] = returnHaxe.substring(haxeString.length, haxeString.length + 5);
			type[set] = -1;
			haxelibList();
		}else{
		type[set] = 1;	
		}
		refreshText();
	}
	public function haxelibList()
	{
	var array = runProcess("haxelib", ["list"]).split("\n");
	for (i in 0...array.length)
	{
		var int = array[i].indexOf(": ");
		list.push(array[i].substring(0, int));
		version.push(array[i].substring(int + 2 + 1, array[i].length - 1 - 1));
		type.push( -1);
	}
	
	}
	
	public function infoHaxelib(lib:String)
	{
		text.x = 0;
		
		var proc = new Process("haxelib", ["info", "openfl"]);
		
		var tim = new Timer(200);
		var release:Bool = false;
		var now:Date = Date.now();
		var releaseArray:Array<String> = [];
		var line:String = "";
		tim.run = function()
		{
		while (true)
		{
		try
		{
		line = proc.stdout.readLine();
		
		if (release)
		{
		var date = Date.fromString(line.substring(0, "2018-05-17 00:16:54".length));
		releaseArray.unshift(dateText(date, now) + line.substring(28, 28 + 70));
		}else{
		if (line.indexOf("Releases:") == 0) release = true;
		}
		
		}catch (err:Dynamic)
		{
			break;
		}
		}
		trace("realse " + releaseArray);
		for (release in releaseArray) text.appendText("\n" + release);
		tim.stop();
		}
	}
	
	public static inline function dateText(newDate:Date, oldDate:Date):String
    {
        var type:String = "";
        var dif = Math.abs(newDate.getTime() - oldDate.getTime());
        
        //set year
        var num:Int = Math.floor(dif/31557600000);
        if (num > 0){type = "year";
        }else{
        //set month
        num = Math.floor(dif/2629800000);
        if (num > 0){type = "month";
        }else{
        //set day    
        num = Math.floor(dif/86400000);
        if (num > 0){type = "day";
        }else{
        //set hour
        num = Math.floor(dif/3600000);
        if (num > 0){type = "hour";
        }else{
        //set min
        num = Math.floor(dif/60000);
        if (num <= 0) num = 1;
        type = "min";
        }}}}
        //plural
        if (num > 1) type += "s";
        return num + " " + type + " ago";
        
    }
	
	public function checkOpenfl()
	{
		var returnOpenfl = runProcess("openfl");
		var i = 0;
		if(returnOpenfl != null)i = returnOpenfl.indexOf("(", 40);
		var set = get("openfl");
		if (i > 0)
		{
		version[set] = returnOpenfl.substring(i + 1, i + 1 + 5);
		type[set] = -1;	
		}else{
		type[set] = 1;
		}
		refreshText();
	}
	public function checkLime()
	{
		var returnLime = runProcess("lime");
		var i = 0;
		if(returnLime != null)i = returnLime.indexOf("(", 40);
		var set = get("lime");
		if (i > 0)
		{
		version[set] = returnLime.substring(i + 1, i + 1 + 5);
		type[set] = -1;	
		}else{
		type[set] = 1;
		}
		refreshText();
	}
	
	public function get(string:String):Int
	{
		return list.indexOf(string);
	}
	
	public function refreshText()
	{
		text.x = logo.x;
		infoInt = -1;
		text.text = "";
		for (i in 0...list.length)
		{
			if (version[i] != null && version[i] != "")
			{
			switch(list[i])
			{
				case "haxe":
				if (version[i] != "4.0.0") type[i] = 2;
				case "openfl":
				if (version[i] != "8.2.0") type[i] = 2;
				case "lime":
				if (version[i] != "4.3.0") type[i] = 2;
			}
			}
			
			var ver = version[i];
			var ty = type[i];
			if (ver == null) ver = "";
			if (ty == null) ty = 0;
			var int:Int = 0;
			
			switch(ty)
			{
				case -1:
				//installed
				text.appendText(list[i] + " installed ");
				int = text.length;
				text.appendText(ver + "\n");
				text.setTextFormat(new TextFormat("_sans", 16, 0x24afc4),int,int + ver.length);
				case 0:
				//finding
				text.appendText(list[i]);
				int = text.length;
				text.appendText(" checking... \n");
				text.setTextFormat(new TextFormat("_sans",16,0), int + 1, int + 1 + 11);
				case 1:
				//failed
				text.appendText(list[i] + " not installed\n");
				case 2:
				//needs update (old version)
				text.appendText(list[i] + " " + ver + " new update available\n");
			}
		}
		
	}
	
	
	private function runProcess (command:String, args:Array<String> = null):String 
	{
		
		if (args == null) args = [];
		
		return switch (PlatformHelper.hostPlatform) 
		{
			
			case WINDOWS: ProcessHelper.runProcess ("", "cmd", [ "/c", command ].concat (args), true, true, true);
			default: ProcessHelper.runProcess ("", command, args, true, true, true);
			
		}
		
	}
	
	public function mouseUp(e:MouseEvent)
	{
		var int = text.getLineIndexAtPoint(mouseX, mouseY - text.y);
		if (int >= 0)
		{
			infoHaxelib(list[infoInt]);
			
			if (infoInt >= 0)
			{
			switch(int)
			{
			case 0:
			//name
			case 1:
			//version
			case 2:
			//path
		    execUrl(path[infoInt]);
			}
			
			}else{
			try
			{
			path[int] = PathHelper.getHaxelib (new Haxelib (list[int]));
			}catch (err:Dynamic)
			{
				return;
			}
			
			text.text = "";
			text.appendText(list[int] + "\n");
			text.appendText("version: " + version[int] + "\n");
			text.appendText("path: " + path[int] + "\n");
			infoInt = int;
			}
		}
	}
	public static function execUrl (url:String) : Void {
    switch (Sys.systemName()) {
        case "Linux", "BSD": Sys.command("xdg-open", [url]);
        case "Mac": Sys.command("open", [url]);
        case "Windows": Sys.command("start", [url]);
        default:
    }
	}

	public function keyDown(e:KeyboardEvent)
	{
		if (e.keyCode == Keyboard.BACKSPACE) refreshText();
	}
	public function update(_)
	{
		var underlineInt = text.getLineIndexAtPoint(mouseX, mouseY - text.y);
		if (underlineInt >= 0)
		{
			underline.y = (underlineInt + 1) * (16 + 4 - 2) + text.y;
			underline.visible = true;
		}else{
			underline.visible = false;
		}
	}
	
	

}
