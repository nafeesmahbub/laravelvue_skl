<?php

namespace App\Http\Middleware;
use App\User;
use Closure;

class JWTToken
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle($request, Closure $next)
    {
        if(!empty($request->token)){
            $token = base64_decode($request->token);
            $token = explode('_',$token);
            if(isset($token[0]) && $token[0]=='ccpro-jwt-salt'){
                if(isset($token[1])){
                    $ccDbName = config('database.cc_db_name');
                    $user = User::selectRaw($ccDbName.".agents.*")
                    ->where(['agents.agent_id' => $token[1], 'active' => 'Y'])
                    ->first();
                    if ($user) {
                        return $next($request);
                    }                    
                }
            }

        }
        return 'Invalid Token';
    }
}
