<template>
    <div class="m-grid__item m-grid__item--fluid m-wrapper">
        <!-- BreadCrumb-->
        <breadcrumb :breadcrumb-data="data.breadcrumb"></breadcrumb>
        <div class="row m-content">
            <div class="col-lg-12">
                <!--begin::Portlet-->
                <div class="m-portlet">
                    <div class="m-portlet__head">
                        <div class="m-portlet__head-caption">
                            <div class="m-portlet__head-title">
                                <span class="m-portlet__head-icon m--hide">
                                    <i class="la la-gear"></i>
                                </span>
                                <h3 class="m-portlet__head-text">
                                    Edit Contact
                                </h3>
                            </div>
                        </div>
                    </div>
                    <!--begin::Form-->
                    <form class="m-form" @submit.prevent="updateContact">
                        <div class="m-portlet__body">
                            <div class="m-form__section m-form__section--first">

                                <div class="form-group m-form__group row" :class="errors.has('phone') || validationErrors.phone ? 'has-error' : ''">
                                    <label class="col-lg-3 col-form-label"  for="phone">Phone:<span class="required">*</span></label>
                                    <div class="col-lg-6">
                                        <input data-vv-as="Phone" name="phone" v-validate="'required|max:13'"  v-model="contact.phone" type="text" class="form-control m-input" placeholder="Enter Phone">
                                        <span class="m-form__help" v-if="errors.has('phone') || validationErrors.phone">
                                            {{ errors.first('phone') || validationErrors.phone[0] }}
                                        </span>
                                    </div>
                                </div>
                                <div class="form-group m-form__group row" :class="errors.has('country') || validationErrors.phone ? 'has-error' : ''" style="display: none">
                                    <label class="col-lg-3 col-form-label"  for="country">Country:<span class="required">*</span></label>
                                    <div class="col-lg-6">
                                        <select data-vv-as="Country" name="country" v-validate="'required'" v-model="contact.country" class="form-control m-input">
                                            <option v-for="(item, index) in countries" :value="index" :key="index">{{item}}</option>
                                        </select>
                                        <!-- <input data-vv-as="Country" name="country" v-validate="'required|max:20'"  v-model="contact.country" type="text" class="form-control m-input" placeholder="Enter Country"> -->
                                        <span class="m-form__help" v-if="errors.has('country') || validationErrors.country">
                                            {{ errors.first('country') || validationErrors.country[0] }}
                                        </span>
                                    </div>
                                </div>
                                 <div class="form-group m-form__group row" :class="errors.has('phone_type') || validationErrors.last_name ? 'has-error' : ''" style="display: none">
                                    <label class="col-lg-3 col-form-label" for="phone_type">Phone Type:<span class="required">*</span></label>
                                    <div class="col-lg-6">
                                        <select data-vv-as="Phone Type" name="phone_type" v-validate="'required'"  v-model="contact.phone_type" class="form-control m-input">
                                            <option value="L">Landline</option>
                                            <option value="M">Mobile</option>
                                        </select>                                        
                                        <span class="m-form__help" v-if="errors.has('phone_type') || validationErrors.phone_type">
                                            {{ errors.first('phone_type') || validationErrors.phone_type[0] }}
                                        </span>
                                    </div>    
                                </div>
                                <div style="display: none;" class="form-group m-form__group row" :class="errors.has('group') || validationErrors.group ? 'has-error' : ''">
                                    <label class="col-lg-3 col-form-label"  for="group">Group:<span class="required">*</span></label>
                                    <div class="col-lg-6">
                                        <!-- <v-select :options="options" :multiple="true" v-model="contact.group" @search="fetchOptions" @keydown.enter.native="preventOnEnter($event)"></v-select> -->
                                        <v-select :options="options" :multiple="true" :clearable="false" :value="contact.group" @input="setSelected" v-model="contact.group" @search="fetchOptions" @keydown.enter.native="preventOnEnter($event)"></v-select>
                                        <span class="m-form__help" v-if="errors.has('group') || validationErrors.group">
                                            {{ errors.first('group') || validationErrors.group[0] }}
                                        </span>
                                    </div>    
                                </div>
                                
                                <div class="form-group m-form__group row" :class="errors.has('first_name') || validationErrors.first_name ? 'has-error' : ''">
                                    <label class="col-lg-3 col-form-label"  for="first_name">First Name:</label>
                                    <div class="col-lg-6">
                                        <input data-vv-as="First Name" name="first_name" v-validate="'max:30'"  v-model="contact.first_name" type="text" class="form-control m-input" placeholder="Enter First Name">
                                        <span class="m-form__help" v-if="errors.has('first_name') || validationErrors.first_name">
                                            {{ errors.first('first_name') || validationErrors.first_name[0] }}
                                        </span>
                                    </div>    
                                </div>
                                <div class="form-group m-form__group row" :class="errors.has('last_name') || validationErrors.last_name ? 'has-error' : ''">
                                    <label class="col-lg-3 col-form-label"  for="last_name">Last Name:</label>
                                    <div class="col-lg-6">
                                        <input data-vv-as="Last Name" name="last_name" v-validate="'max:30'"  v-model="contact.last_name" type="text" class="form-control m-input" placeholder="Enter Last Name">
                                        <span class="m-form__help" v-if="errors.has('last_name') || validationErrors.last_name">
                                            {{ errors.first('last_name') || validationErrors.last_name[0] }}
                                        </span>
                                    </div>    
                                </div>
                                <div class="form-group m-form__group row" :class="errors.has('company') || validationErrors.phone ? 'has-error' : ''">
                                    <label class="col-lg-3 col-form-label"  for="company">Company:</label>
                                    <div class="col-lg-6">
                                        <input data-vv-as="Company" name="company" v-validate="'max:20'"  v-model="contact.company" type="text" class="form-control m-input" placeholder="Enter Company">
                                        <span class="m-form__help" v-if="errors.has('company') || validationErrors.company">
                                            {{ errors.first('company') || validationErrors.company[0] }}
                                        </span>
                                    </div>
                                </div>
                                

                            </div>
                        </div>
                        <div class="m-portlet__foot m-portlet__foot--fit">
                            <div class="m-form__actions m-form__actions">
                                <button type="submit" class="btn btn-primary">Submit</button>
                            </div>
                        </div>
                    </form>
                    <!--end::Form-->
                </div>
                <!--end::Portlet-->

            </div>
        </div>
    </div>   
</template>

<script>
import AppComponent from '../../components/AppComponent'
export default {
  extends: AppComponent,
    
  data() {
    return {
      options: [],
      countries: {},
      contact: {},
      validationErrors: {},
      data:{}
    };
  },
  mounted(){
      if(this.$route.params.id){ 
          let id = this.$route.params.id;
          this.getContactById(id);
          this.getCountries();
          this.bindCurrentRoute("AdminContactList");
      }
  },
  methods: {
    setSelected(value) {
        console.log(value);
    },
    preventOnEnter(event){        
        event.preventDefault();       
    },
      fetchOptions (search, loading) {
        loading(true);
        var url = BASE_URL+`admin-api/search-list?q=${escape(search)}`;
        axios.get(url).then((res) => 
        {          
            //this.options = res.data.data;
            this.options = this.$processVselectData(res.data.data,'name','id');
            //console.log(this.options);                                 
            loading(false);
        })
        .catch(function (error) {
            console.log(error.response);
            loading(false);
        });
    },
    // Update Contact
    updateContact() {
        // Update
        this.$validator.validateAll().then((result) => { 
            if(result == true){
                if(typeof commonLib != 'undefined'){
                    commonLib.blockUI({target: ".m-content",animate: true,overlayColor: 'none'});
                }
                let vm = this;
                this.contact._method = 'PUT';
                axios.post(BASE_URL+"admin-api/contacts/"+this.$route.params.id, this.contact).then((res) => 
                {                    
                    commonLib.iniToastrNotification(res.data.response_msg.type, res.data.response_msg.title, res.data.response_msg.message);
                    if(res.data.response_msg.type == 'success'){
                        this.contact = {};
                        this.$router.push({name:'AdminContactList'});                        
                    }
                    commonLib.unblockUI(".m-content");
                })
                .catch(function (error) { 
                    vm.validationErrors = error.response.data;
                    commonLib.unblockUI(".m-content");
                });

            }

        });  
      
    },
    getContactById(id) {
        let vm = this;
        var refUrl = BASE_URL+'admin-api/contacts/'+id+'/edit';
        if(typeof commonLib != 'undefined'){
            commonLib.blockUI({target: ".m-content",animate: true,overlayColor: 'none'});
        }
        axios.get(refUrl).then((res) => 
        {
            this.contact = res.data.data.contact;
            //this.contact.group = {'label': res.data.data.groups[0].name, 'code': res.data.data.groups[0].id};            
            this.options = this.$processVselectData(res.data.groupList,'name','id');            
            this.contact.group = this.$processVselectData(res.data.data.groups,'name','id');
            this.data = res.data;
            this.$setDocumentTitle(this.data.title);
            commonLib.unblockUI(".m-content");
        })
        .catch(function (error) {
            console.log(error.response);
            commonLib.unblockUI(".m-content");
        });

    },
    onChange(event) {
        var code = event.target.value;
        this.getCountryPhoneCode(code);
    },
    getCountryPhoneCode(code){      

        axios.get(BASE_URL+'admin-api/country-phone-code/'+code).then((res) => 
        { 
            this.contact.phone = res.data;            
        })
        .catch(function (error) {
            console.log(error.response);
        });
    },
    getCountries(){      

        axios.get(BASE_URL+'admin-api/contact-country-list').then((res) => 
        { 
            this.countries = res.data;
            console.log(this.countries);
        })
        .catch(function (error) {
            console.log(error.response);
        });
    },
  }
};
</script>
