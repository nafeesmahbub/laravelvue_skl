<?php
$authUser = Session::get('loginUser');
//dd(Auth::guard('admin')->user());
?>
<header id="m_header" class="m-grid__item m-header"  m-minimize-offset="200" m-minimize-mobile-offset="200">
    <div class="m-container m-container--fluid m-container--full-height">
        <div class="m-stack m-stack--ver m-stack--desktop">
            <div class="m-stack__item m-brand  m-brand--skin-dark ">
                <div class="m-stack m-stack--ver m-stack--general">
                    <div class="m-stack__item m-stack__item--middle m-brand__logo app-header-logo">
                        <a href="{{ route('dashboard') }}" target="_blank" class="m-brand__logo-wrapper">
                            <img alt="" src="{{ url('public/assets/demo/default/media/img/logo/logo.png') }}"/>
                        </a>
                    </div>
                    <div class="m-stack__item m-stack__item--middle m-brand__tools">
                        <a href="javascript:;" id="m_aside_left_minimize_toggle" class="m-brand__icon m-brand__toggler m-brand__toggler--left m--visible-desktop-inline-block">
                            <span></span>
                        </a>
                        <a href="javascript:;" id="m_aside_left_offcanvas_toggle" class="m-brand__icon m-brand__toggler m-brand__toggler--left m--visible-tablet-and-mobile-inline-block">
                            <span></span>
                        </a>
                        <a id="m_aside_header_menu_mobile_toggle" href="javascript:;" class="m-brand__icon m-brand__toggler m--visible-tablet-and-mobile-inline-block">
                            <span></span>
                        </a>
                        <a id="m_aside_header_topbar_mobile_toggle" href="javascript:;" class="m-brand__icon m--visible-tablet-and-mobile-inline-block">
                            <i class="flaticon-more"></i>
                        </a>
                    </div>
                </div>
            </div>
            

            <div class="m-stack__item m-stack__item--fluid m-header-head" id="m_header_nav">
                <!-- BEGIN: Topbar -->
                <div id="m_header_topbar" class="m-topbar  m-stack m-stack--ver m-stack--general m-stack--fluid">
                   <div class="m-stack__item m-topbar__nav-wrapper">
                      <ul class="m-topbar__nav m-nav m-nav--inline">                      
                      <label>{{ Auth::guard('admin')->user()->name }}</label>
                         <li class="m-nav__item m-topbar__user-profile m-topbar__user-profile--img  m-dropdown m-dropdown--medium m-dropdown--arrow m-dropdown--header-bg-fill m-dropdown--align-right m-dropdown--mobile-full-width m-dropdown--skin-light" m-dropdown-toggle="click">
                            <a href="#" class="m-nav__link m-dropdown__toggle">
                            
                                <span class="m-topbar__userpic">
                                    <img src="{{ url('public/assets/app/media/img/users/profile.png')}}" class="m--img-rounded m--marginless m--img-centered" alt=""/>
                                </span>
                                <span class="m-topbar__username m--hide">
                                    {{ Auth::guard('admin')->user()->name }}
                                </span>
                            </a>
                            <div class="m-dropdown__wrapper">
                               <span class="m-dropdown__arrow m-dropdown__arrow--right m-dropdown__arrow--adjust"></span>
                               <div class="m-dropdown__inner">
                                  <div class="m-dropdown__header m--align-center" style="background-color: #7948e1">
                                    <div class="m-card-user m-card-user--skin-dark">
                                        <div class="m-card-user__pic">
                                            <img src="{{ url('public/assets/app/media/img/users/profile.png') }}" class="m--img-rounded m--marginless" alt=""/>
                                        </div>
                                        <div class="m-card-user__details">
                                            <span class="m-card-user__name m--font-weight-500">
                                                    {{ Auth::user()->name}}
                                            </span>
                                            <a href="javascript:void(0)" class="m-card-user__email m--font-weight-300 m-link">
                                                {{ Auth::guard('admin')->user()->email }}
                                            </a>
                                        </div>
                                    </div>
                                  </div>
                                  <div class="m-dropdown__body">
                                     <div class="m-dropdown__content">
                                        <ul class="m-nav m-nav--skin-light">
                                           <li class="m-nav__section m--hide">
                                              <span class="m-nav__section-text">Section</span>
                                           </li>
                                            <li class="m-nav__separator m-nav__separator--fit"></li>
                                            <li class="m-nav__item">
                                                <a href="{{ route('admin.logout') }}" class="btn m-btn--pill btn-secondary m-btn m-btn--custom m-btn--label-brand m-btn--bolder">
                                                    Admin Logout
                                                </a>
                                                
                                            </li>
                                        </ul>
                                     </div>
                                  </div>
                               </div>
                            </div>
                         </li>
                         
                      </ul>
                   </div>
                </div>
                <!-- END: Topbar -->			
             </div>


        </div>
    </div>
</header>