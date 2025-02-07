<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Foundation\Bus\DispatchesJobs;
use Illuminate\Routing\Controller as BaseController;
use Illuminate\Foundation\Validation\ValidatesRequests;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;

class Controller extends BaseController
{
    use AuthorizesRequests, DispatchesJobs, ValidatesRequests;

    /**
     * get all constant variables
     */
    public function getConstVar(){
        return config("dashboard_constant");
    }
    /**
     * get js plugin list
     */
    public function getJsPluginList(){
        return config("js_plugin_list");
    }
    /**
     * get js plugin files
     * @param array $fileKey
     */
    public function getJsPlugin($fileKey){
        $pluginFiles = [
            'js' => [], 'css' => []
        ];
        if(!empty($fileKey)){
            $jsPluginList = config("js_plugin_list");
            foreach($fileKey as $item){  
                if(isset($jsPluginList[$item]['css'])){
                    $pluginFiles['css'] = array_merge($pluginFiles['css'],$jsPluginList[$item]['css']);
                }
                if(isset($jsPluginList[$item]['js'])){
                    $pluginFiles['js'] = array_merge($pluginFiles['js'],$jsPluginList[$item]['js']);
                }
                
            }    

        } 
        return $pluginFiles;

    }
    /**
     * check file exists
     */
    public function isFileExists(Request $request){
        $filePath = $request->query('filepath');
        if(file_exists($filePath)){
            return true;
        }
        return false;
    }
}
