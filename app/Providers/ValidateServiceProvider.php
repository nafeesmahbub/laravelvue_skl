<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Validator;

class ValidateServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap the application services.
     *
     * @return void
     */
    public function boot()
    {
        Validator::extend('OldPasswordCheck', function ($attribute, $value, $parameters, $validator) { 
            $userData = \Auth::user();  
            $oldPassword = $value;
            if(\Hash::check($oldPassword, $userData->password)){
                return true;
            }
            return false;
        });

        Validator::replacer('OldPasswordCheck', function($message, $attribute, $rule, $parameters) {
            return str_replace($message, "Old Password Not Matched", $message);
        });
    }

    /**
     * Register the application services.
     *
     * @return void
     */
    public function register()
    {
        //
    }
}
