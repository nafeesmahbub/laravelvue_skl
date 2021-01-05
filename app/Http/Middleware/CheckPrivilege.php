<?php

namespace App\Http\Middleware;

use Closure;

class CheckPrivilege
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle($request, Closure $next, $privileges)
    {
        $privileges = explode("|",$privileges); 
        if($request->session()->exists('loginUser')){
            $userPrivileges = explode(",",$request->session()->get('loginUser.privileges')); 
            if(in_array("*",$userPrivileges)){
                return $next($request);
                
            }else if(!empty($userPrivileges)){
                foreach($userPrivileges as $pre){
                    $pre = trim($pre);
                    if(in_array($pre,$privileges)){
                        return $next($request);
                    } 
                }
            }
        }
        return redirect('/');
        
    }
}
