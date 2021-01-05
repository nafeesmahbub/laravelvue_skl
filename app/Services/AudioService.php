<?php

namespace App\Services;

use App\Models\UserSession;
use Cassandra\Date;
use Illuminate\Http\Request;
use App\Models\Audio;
use App\Models\AudioSegment;
use App\Models\AudioProcessLog;
use App\Services\LogService;
use DB;
use Auth;


class AudioService extends AppService
{
    public function __construct()
    {
        $this->user = \Session::get('loginUser');
        $this->LogService = new LogService();
    }

    /**
     * get pagination data
     */
    public function getPagination($request)
    {
        // Get list
        $queryParam = $request->query();
        $type = \Auth::user()->type;
        if ($type == config("dashboard_constant.USER_ROLE_TYPE.Admin")) {
            $query = AudioSegment::leftJoin('users', 'users.username', '=', 'audio_segments.user_id')
                ->orderBy('audio_segments.assign_at', 'DESC');
        } else if ($type == config("dashboard_constant.USER_ROLE_TYPE.Supervisor")) {
            $query = AudioSegment::leftJoin('users', 'users.username', '=', 'audio_segments.user_id')
                ->where("audio_segments.supervisor_id", Auth::user()->username)
                ->orderBy('audio_segments.assign_at', 'DESC');
        } else if ($type == config("dashboard_constant.USER_ROLE_TYPE.Tester")) {
            $query = AudioSegment::leftJoin('users', 'users.username', '=', 'audio_segments.user_id')
                ->where("audio_segments.tester_id", Auth::user()->username)
                ->orderBy('audio_segments.assign_at', 'DESC');
        } else {
            $query = AudioSegment::where("user_id", Auth::user()->username)
                ->leftJoin('users', 'users.username', '=', 'audio_segments.user_id')
                ->orderBy('audio_segments.created_at', 'DESC');
        }

        if (isset($queryParam['id']) && !empty($queryParam['id'])) {
            $query->where("as_id", $queryParam['id']);
        }
        if (isset($queryParam['callid']) && !empty($queryParam['callid'])) {
            $query->where("callid", $queryParam['callid']);
        }
        if (isset($queryParam['status']) && !empty($queryParam['status'])) {
            $query->where("status", $queryParam['status']);
        }
        if (isset($queryParam['party']) && !empty($queryParam['party'])) {
            $query->where("party", $queryParam['party']);
        }
        if (isset($queryParam['brand']) && !empty($queryParam['brand'])) {
            $query->where("brand_name", $queryParam['brand']);
        }
        if (isset($queryParam['duration']) && !empty($queryParam['duration'])) {
            $query->where("audio_duration", $queryParam['duration']);
        }
        if (isset($queryParam['gender']) && !empty($queryParam['gender'])) {
            $query->where("audio_gender", $queryParam['gender']);
        }
        if (isset($queryParam['emotion']) && !empty($queryParam['emotion'])) {
            $query->where("audio_emotion", $queryParam['emotion']);
        }
        $data = $query->paginate(config('dashboard_constant.PAGINATION_LIMIT'));
        
        foreach ($data as $key => $value) {
            $value->file_path = 'api/get-audio-file/'.$value->as_id;
        }

        return $this->paginationDataFormat($data->toArray());
    }

    // check if user has assigned audio
    public function checkAssignAudio()
    { 
        return AudioSegment::where("user_id", Auth::user()->username)
            ->where(function ($query) {
                $query->where('status', '=', config('dashboard_constant.AUDIO_STATUS.NEW'))
                    ->orWhere('status', '=', config('dashboard_constant.AUDIO_STATUS.INPROGRESS'))
                    ->orWhere('status', '=', config('dashboard_constant.AUDIO_STATUS.REPEAT'));
            })
            ->count();
    }
 
    public function createWork()
    {
        if (Auth::user()->type == config("dashboard_constant.USER_ROLE_TYPE.Agent")) {
            if ($this->checkAssignAudio()) {
                $data = AudioSegment::where("user_id", Auth::user()->username)
                    ->where(function ($query) {
                        $query->where('status', '=', config('dashboard_constant.AUDIO_STATUS.NEW'))
                            ->orWhere('status', '=', config('dashboard_constant.AUDIO_STATUS.INPROGRESS'))
                            ->orWhere('status', '=', config('dashboard_constant.AUDIO_STATUS.REPEAT'));
                    })
                    ->first();
                if($data){
                    if($data->status==config('dashboard_constant.AUDIO_STATUS.REPEAT')){
                        $current_time = date("Y-m-d H:i:s");
                        DB::table('audio_segments')->where("as_id", $data->as_id)
                            ->update([
                                'user_id' => Auth::user()->username,
                                'assign_at' => $current_time
                            ]);

                        $AudioProcessLog = new AudioProcessLog();
                        $AudioProcessLog->as_id = $data->as_id;
                        $AudioProcessLog->user_id = \Auth::user()->username;
                        $AudioProcessLog->user_type = \Auth::user()->type;
                        $AudioProcessLog->assign_time = $current_time;
                        $AudioProcessLog->log_start_time = $current_time;
                        $AudioProcessLog->save();
                    }
                }
            } else {
                $data = $this->assignAudio();
            }

            if ($data) {
                $data->file_path = 'api/get-audio-file/'.$data->as_id;
                return $data->toArray();
            }
        }
        return [];
    }

    public function checkSupervisorAssignAudio()
    {
        return AudioSegment::where("supervisor_id", Auth::user()->username)
            ->where('status', '=', config('dashboard_constant.AUDIO_STATUS.DRAFT'))
            ->count();
    }

    public function createSupervisorWork()
    {
        if ($this->checkSupervisorAssignAudio()) {
            $data = AudioSegment::where("supervisor_id", Auth::user()->username)
                ->where('status', '=', config('dashboard_constant.AUDIO_STATUS.DRAFT'))
                ->first();
        } else {
            $data = $this->assignAudioToSupervisor();
        }

        if ($data) {
            $data->file_path = 'api/get-audio-file/'.$data->as_id;
            return $data->toArray();
        }

        return [];
    }

    public function checkTesterAssignAudio()
    {
        return AudioSegment::where("tester_id", Auth::user()->username)
            ->where('status', '=', config('dashboard_constant.AUDIO_STATUS.PUBLISHED'))
            ->count();
    }

    public function createTesterWork()
    {

        if ($this->checkTesterAssignAudio()) {
            $data = AudioSegment::where("tester_id", Auth::user()->username)
                ->where('status', '=', config('dashboard_constant.AUDIO_STATUS.PUBLISHED'))
                ->first();
        } else {
            $data = $this->assignAudioToTester();
        }

        if ($data) {
            $data->file_path = 'api/get-audio-file/'.$data->as_id;
            return $data->toArray();
        }

        return [];
    }

    // assign audio to user
    public function assignAudio()
    { 
        $data = AudioSegment::where("user_id", '')->where('audio_duration', '<=', 10)
            ->where(function ($query) {
                $query->where("status", config('dashboard_constant.AUDIO_STATUS.NEW'))
                    ->orWhere('status', '=', config('dashboard_constant.AUDIO_STATUS.INPROGRESS'))
                    ->orWhere('status', '=', config('dashboard_constant.AUDIO_STATUS.REPEAT'));
            })
            ->first();

        if ($data) {
            $current_time = date("Y-m-d H:i:s");
            DB::table('audio_segments')->where("as_id", $data->as_id)
                ->update(['user_id' => Auth::user()->username, 'assign_at' => $current_time]);

            $AudioProcessLog = new AudioProcessLog();
            $AudioProcessLog->as_id = $data->as_id;
            $AudioProcessLog->user_id = \Auth::user()->username;
            $AudioProcessLog->user_type = \Auth::user()->type;
            $AudioProcessLog->assign_time = $current_time;
            $AudioProcessLog->log_start_time = $current_time;
            $AudioProcessLog->save();
            return $data;
        }
    }

    public function assignAudioToTester(){
        $data = AudioSegment::where("status", config('dashboard_constant.AUDIO_STATUS.PUBLISHED'))
            ->first();

        if ($data) {

            $log_id = $this->LogService->genAudioProcesLogId();

            DB::table('audio_segments')->where("callid", $data->callid)
                ->where("segment_id", $data->segment_id)
                ->where("party", $data->party)
                ->update(['tester_id' => Auth::user()->username, 'log_id' => $log_id]);

            $AudioProcessLog = new AudioProcessLog();
            $AudioProcessLog->log_id = $log_id;
            $AudioProcessLog->callid = $data->callid;
            $AudioProcessLog->segment_id = $data->segment_id;
            $AudioProcessLog->user_id = \Auth::user()->username;
            $AudioProcessLog->brand_name = $data->brand_name;
            $AudioProcessLog->party = $data->party;

            $AudioProcessLog->user_type = \Auth::user()->type;

            $AudioProcessLog->audio_log_status = '';

            $AudioProcessLog->assign_time = date("Y-m-d H:i:s");
            $AudioProcessLog->start_time = date("Y-m-d H:i:s");

            $AudioProcessLog->log_start_time = date("Y-m-d H:i:s");
            $AudioProcessLog->save();

            $data->log_id = $log_id;

            return $data;
        }
    }

    public function assignAudioToSupervisor(){
        $data = AudioSegment::where("status", config('dashboard_constant.AUDIO_STATUS.DRAFT'))
            ->first();

        if ($data) {
            $current_time = date("Y-m-d H:i:s");
            DB::table('audio_segments')->where("as_id", $data->as_id)
                ->update([
                    'supervisor_id' => Auth::user()->username,
                    'sp_assign_at' => $current_time
                ]);

            $AudioProcessLog = new AudioProcessLog();
            $AudioProcessLog->as_id = $data->as_id;
            $AudioProcessLog->user_id = \Auth::user()->username;
            $AudioProcessLog->user_type = \Auth::user()->type;
            $AudioProcessLog->assign_time = $current_time;
            $AudioProcessLog->log_start_time = $current_time;
            $AudioProcessLog->save();
            return $data;
        }
    }

    public function changeAudioStatus($request, $asr_id){
        $data = AudioSegment::where("as_id", $asr_id)->first();
        if ($data) {
            // $authUser = \Session::get('loginUser');
            if(\Auth::user()->type=='AG'){
                DB::table('audio_segments')->where("as_id", $asr_id)
                    ->update([
                        'status' => $request->input('status'), 
                        'audio_status_updated_at' => date("Y-m-d H:i:s")
                    ]);
            }

            $this->insertStartAudioProgressLog($request, $asr_id);
            return $this->processServiceResponse(true, "Status Change (Audio in progress)!", $data);
        }
    }

    public function insertStartAudioProgressLog($request, $asr_id){
        $audioPl = $this->getAudioProcessLog($asr_id);

        $flag = '';
        $msg = '';
        $affectedRows = '';
        if(empty($audioPl->start_time) || $audioPl->start_time == '0000-00-00 00:00:00'){
            $to = date("Y-m-d H:i:s");
            $from = date("Y-m-d H:i:s", strtotime('-24 hours', strtotime($to)));
            $sql = 'UPDATE audio_process_log SET ';
            $sql .= 'start_time="'.date("Y-m-d H:i:s").'" ';
            $sql .= 'WHERE log_start_time BETWEEN :from AND :to AND ';
            $sql .= 'as_id = :as_id AND ';
            $sql .= 'user_id = :user_id AND ';
            $sql .= 'user_type = :user_type ';
            $sql .= 'ORDER BY log_start_time desc limit 1';
            $updateConditions = [
                'from'       => $from,
                'to'         => $to,
                'as_id'      => $asr_id,
                'user_id'    => \Auth::user()->username,
                'user_type'  => \Auth::user()->type,
            ];
            $affectedRows = DB::update($sql, $updateConditions);

            if($affectedRows){
                $flag = true;
                $msg = "Audio process log has been updated successfully!";
            }else{
                $flag = false;
                $msg = "Audio process log has not been updated successfully!";
            }
        }
        return $this->processServiceResponse($flag, $msg, $affectedRows);
    }

    public function addAudioProcessLog($request, $asr_id, $agent_ht, $audio_ht, $default_status, $text_bangla, $currentTime){
        $transcript_flag = $request->input('transcript_flag');
        $error_type = '';
        $error_comment = '';
        if ($transcript_flag==config('dashboard_constant.AUDIO_REPORT_ERROR_TYPE_VALUE.TRN')) {
            $error_type = $request->input('transcript_flag');
            $error_comment = $request->input('transcript_comment');
        }

        // $authUser = \Session::get('loginUser');
        // $to = date("Y-m-d H:i:s");        
        // $from = date("Y-m-d H:i:s", strtotime('-24 hours', strtotime($to)));
        // $affectedRows = AudioProcessLog::whereBetween('log_start_time', [$from, $to])
        //     ->where('as_id', $asr_id)
        //     ->where('user_type', \Auth::user()->type)
        //     ->where('user_id', \Auth::user()->username)
        //     ->update([
        //         'end_time' => $currentTime,
        //         'audio_log_status' => $default_status,
        //         'agent_ht' => $agent_ht,
        //         'audio_ht' => $audio_ht,
        //         'text_bangla' => $text_bangla,
        //         'error_type' => $error_type,
        //         'error_comment' => $error_comment,
        //     ]);


        $to = date("Y-m-d H:i:s");
        $from = date("Y-m-d H:i:s", strtotime('-24 hours', strtotime($to)));
        $sql = 'UPDATE audio_process_log SET ';
        $sql .= 'end_time="'.$currentTime.'", ';
        $sql .= 'audio_log_status="'.$default_status.'", ';
        $sql .= 'agent_ht="'.$agent_ht.'", ';
        $sql .= 'audio_ht="'.$audio_ht.'", ';
        $sql .= 'text_bangla="'.$text_bangla.'", ';
        $sql .= 'error_type="'.$error_type.'", ';
        $sql .= 'error_comment="'.$error_comment.'" ';
        $sql .= 'WHERE log_start_time BETWEEN :from AND :to AND ';
        $sql .= 'as_id = :as_id AND ';
        $sql .= 'user_id = :user_id AND ';
        $sql .= 'user_type = :user_type ';
        $sql .= 'ORDER BY log_start_time desc limit 1';
        $updateConditions = [
            'from'       => $from,
            'to'         => $to,
            'as_id'      => $asr_id,
            'user_id'    => \Auth::user()->username,
            'user_type'  => \Auth::user()->type,
        ];
        $affectedRows = DB::update($sql, $updateConditions);

        if($affectedRows){
            return $this->processServiceResponse(true, "Audio process log has been updated successfully!", $affectedRows);
        }

        return $this->processServiceResponse(false, "Audio process log has not been updated successfully!", $affectedRows);
    }

    public function createSegment($request, $asr_id){
        $audio_quality = $request->input('audio_quality');
        $default_status = $request->input('status');

        $rules = [];
        if($audio_quality != config('dashboard_constant.AUDIO_STATUS.ERROR')){
            $rules = [
                'text_bangla' => 'required',
                'audio_emotion' => 'required',
                'audio_gender' => 'required',
                'audio_status' => 'required',
                'language_type' => 'required',
            ];            
        }
        \Validator::make($request->all(), $rules)->validate();

        $audio = AudioSegment::where('as_id', $asr_id)->first();
        if (empty($audio)) {
            return $this->processServiceResponse(false, "Your request is wrong. This segment is not valid!", null);
        }

        // var_dump($default_status);
        $default_status = ($default_status == config('dashboard_constant.AUDIO_STATUS.DISCARD')) ? $default_status : config('dashboard_constant.AUDIO_STATUS.DRAFT');
        // $default_status = config('dashboard_constant.AUDIO_STATUS.DRAFT');
        // $authUser = \Session::get('loginUser');
        // $from = date("Y-m-d")." 00:00:00";
        // $to = date("Y-m-d")." 23:59:59";
        // $audioPl = AudioProcessLog::whereBetween('log_start_time', [$from, $to])
        //             ->where('as_id', $asr_id)
        //             ->where('user_type', $authUser['type'])
        //             ->where('user_id', $authUser['username'])
        //             ->first();
        $audioPl = $this->getAudioProcessLog($asr_id);

        $currentTime = date("Y-m-d H:i:s");
        $agent_work_time = (strtotime($currentTime) - strtotime($audioPl->assign_time)) + $audio->ag_work_time;
        $agent_ht = strtotime($currentTime) - strtotime($audioPl->start_time);
        $audio_ht = strtotime($currentTime) - strtotime($audioPl->assign_time);
        $text_bangla = empty($request->input('text_bangla')) ? '' : $request->input('text_bangla');
        $comments = '';
        $language_type = (empty($request->input('language_type')) || $request->input('language_type') != 'L') ? '' : $request->input('language_type');
        if($audio_quality == config('dashboard_constant.AUDIO_STATUS.ERROR')){
            $comments = $text_bangla;
            $text_bangla = '';
        }
        // var_dump($default_status);

        // Create or Update
        $update_data = [
                'text_bangla' => $text_bangla,
                'text_english' => empty($request->input('text_english')) ? '' : $request->input('text_english'),
                'audio_gender' => empty($request->input('audio_gender')) ? '' : $request->input('audio_gender'),
                'audio_emotion' => empty($request->input('audio_emotion')) ? '' : $request->input('audio_emotion'),
                'audio_status' => empty($request->input('audio_status')) ? '' : $request->input('audio_status'),
                'comment' => $comments,
                'status' => $default_status,
                'ag_work_time' => $agent_work_time,
                'language_type' => $language_type,
                'audio_quality' => empty($audio_quality) ? '' : $audio_quality,
            ];
        // dd($update_data);

        $status = \DB::table('audio_segments')->where('as_id', $asr_id)            
            ->update($update_data);

        if ($status) {
            $this->addAudioProcessLog($request, $asr_id, $agent_ht, $audio_ht, $default_status, $text_bangla, $currentTime);
            // $this->removeSessionAudioSegmentData();
            $msg = "Segment Audio has been updated Successfully!";
            $result = true;
            if($default_status == 'C'){
                $msg = "Segment Audio has been discarded Successfully!";
                $result = "W";
            }
            return $this->processServiceResponse($result, $msg, $status);
        }

        return $this->processServiceResponse(false, "Segment Audio has not been updated successfully!", $status);
    }

    public function publishSegment($request, $asr_id){
        $audio_quality = $request->input('audio_quality');
        $transcript_flag = $request->input('transcript_flag');
        $rules = [];
        if($audio_quality !== config('dashboard_constant.AUDIO_STATUS.ERROR')){
            $rules = [
                'text_bangla' => 'required',
                // 'audio_emotion' => 'required',
                'audio_gender' => 'required',
                'audio_status' => 'required'
            ];
        }
        if ($transcript_flag==config('dashboard_constant.AUDIO_REPORT_ERROR_TYPE_VALUE.TRN')) {
            $rules['transcript_comment'] = 'required';
            $user_id = '';
        }
        \Validator::make($request->all(), $rules)->validate();
        // dd($request);

        $audio = AudioSegment::where('as_id', $asr_id)->first();
        if (empty($audio)) {
            return $this->processServiceResponse(false, "Your request is wrong. This segment is not valid!", null);
        }

        $default_status = config('dashboard_constant.AUDIO_STATUS.PUBLISHED');
        if($audio_quality == config('dashboard_constant.AUDIO_STATUS.ERROR')){
            $default_status = config('dashboard_constant.AUDIO_STATUS.ERROR');
        }
        // $authUser = \Session::get('loginUser');
        // $from = date("Y-m-d")." 00:00:00";
        // $to = date("Y-m-d")." 23:59:59";
        // $audioPl = AudioProcessLog::whereBetween('log_start_time', [$from, $to])
        //             ->where('as_id', $asr_id)
        //             ->where('user_type', $authUser['type'])
        //             ->where('user_id', $authUser['username'])
        //             ->first();
        $audioPl = $this->getAudioProcessLog($asr_id);

        $currentTime = date("Y-m-d H:i:s");
        $sp_work_time = (strtotime($currentTime) - strtotime($audioPl->assign_time)) + $audio->sp_work_time;
        $agent_ht = strtotime($currentTime) - strtotime($audioPl->start_time);
        $audio_ht = strtotime($currentTime) - strtotime($audioPl->assign_time);
        // dd($default_status);

        $sp_transcript_comment = '';
        $tr_count = 0;
        $user_id = $audio->user_id;
        $supervisor_id = \Auth::user()->username;
        if ($transcript_flag==config('dashboard_constant.AUDIO_REPORT_ERROR_TYPE_VALUE.TRN')) {
            $sp_transcript_comment = $request->input('transcript_comment');
            $tr_count = 1 + $audio->tr_count;
            $default_status = config('dashboard_constant.AUDIO_STATUS.REPEAT');
            // $user_id = '';
            // $supervisor_id = '';
        }

        $text_bangla = $request->input('text_bangla');

        // Create or Update
        $update_data = [
            'text_bangla' => $request->input('text_bangla'),
            'text_english' => $request->input('text_english'),
            'audio_gender' => $request->input('audio_gender'),
            'audio_emotion' => $request->input('audio_emotion'),
            'audio_status' => $request->input('audio_status'),
            'comment' => $request->input('comment'),
            'language_type' => $request->input('language_type'),
            'sp_comment' => $request->input('sp_comment'),
            'audio_status_updated_at' => $currentTime,
            'status' => $default_status,
            'sp_work_time' => $sp_work_time,
            'audio_quality' => $audio_quality,
            'sp_transcript_comment' => $sp_transcript_comment,
            'tr_count' => $tr_count,
            'user_id' => $user_id,
            'supervisor_id' => $supervisor_id,
        ];
        // dd($update_data);
        $status = \DB::table('audio_segments')->where('as_id', $asr_id)
            ->update($update_data);

        if ($status) {
            $this->addAudioProcessLog($request, $asr_id, $agent_ht, $audio_ht, $default_status, $text_bangla, $currentTime);
            // $this->removeSessionAudioSegmentData();
            return $this->processServiceResponse(true, "Segment Audio Added Successfully!", $status);
        }

        return $this->processServiceResponse(false, "Segment Audio Added Failed!", $status);
    }

    public function doneSegment($request, $call_id, $segment_id, $party, $log_id)
    {
        $audio = AudioSegment::where('callid', $call_id)->where('segment_id', $segment_id)->where('party', $party)->first();
        if (empty($audio)) {
            return $this->processServiceResponse(false, "Segment Audio Edit Failed!", null);
        }

        // Create or Update

        $status = \DB::table('audio_segments')->where('callid', $call_id)
            ->where('segment_id', $segment_id)
            ->where('party', $party)
            ->update([
                //'supervisor_id' => \Auth::user()->id,
                'text_bangla' => $request->input('text_bangla'),
                'text_english' => $request->input('text_english'),
                'audio_gender' => $request->input('audio_gender'),
                'audio_emotion' => $request->input('audio_emotion'),
                'audio_status' => $request->input('audio_status'),
                'comment' => $request->input('comment'),
                'audio_status_updated_at' => date("Y-m-d H:i:s"),
                'status' => config('dashboard_constant.AUDIO_STATUS.FINISHED'),
            ]);

        if ($status) {
            $this->logAudioDone($request, $call_id, $segment_id, $party, $log_id);
            return $this->processServiceResponse(true, "Segment Audio Added Successfully!", $status);
        }

        return $this->processServiceResponse(false, "Segment Audio Added Failed!", $status);
    }
    /*
        GET audio segment data
    */
    public function getAudioSegmentData($asr_id){
        $data=[];
        if(!empty($asr_id))
            $data = AudioSegment::where('as_id', $asr_id)->first();
        return $data;
    }

    public function audioCropProcess($request){ 
        if(!empty($request->input('regions'))){
            $waveCropLibPath = config("dashboard_constant.WAVECUT_PATH");
            $rootPath = config("dashboard_constant.AUDIO_PATH_FILE"); 

            $callid = $request->input('callid');
            $yy_mm_dd = date('Y-m-d', substr($callid, 0, 10));
            $party = $request->input('party');
            $segmentId = $request->input('segment_id');
            $brandName = $request->input('brand_name');
            $totalRegions = count($request->input('regions') );
            
            if(!empty($callid) && $totalRegions > 0){ 
                $srcFile = $rootPath.$yy_mm_dd.'/'.$callid.'/'.$party.'/'.$callid.'_'.$segmentId.'.wav';
                $segmentDetail = $this->getMaxSegmentDetail($callid, $party, $brandName);
                $newSegmentId = $segmentDetail->segment_id + 1;
                $dstFile = $rootPath.$yy_mm_dd.'/'.$callid.'/'.$party.'/'.$callid.'_'.$newSegmentId.'.wav'; 
                
                $cmd = $waveCropLibPath.' ' .$srcFile.' ' .$dstFile.' '.$totalRegions;
                
                foreach($request->input('regions') as $rkey => $region){ 
                    $cmd .= ' ' . round($region['start_region'], 4) . ' ' . round($region['end_region'], 4);
                    
                } 
                // dump($cmd); die();
                exec($cmd,$output);

                $firstCreateSegment = $this->createCropSegment($request->input(), $newSegmentId);
                // update old audio segment status to  (crop|T)
                $audio = AudioSegment::where('as_id', $request->input('as_id'))->first();
                $audioPl = $this->getAudioProcessLog($request->input('as_id'));
                $currentTime = date("Y-m-d H:i:s");
                $agent_ht = strtotime($currentTime) - strtotime($audioPl->start_time);
                $audio_ht = strtotime($currentTime) - strtotime($audioPl->assign_time);
                $sp_work_time = $audio->sp_work_time;
                $ag_work_time = $audio->ag_work_time;

                if(\Auth::user()->type == 'AG')
                    $ag_work_time = (strtotime($currentTime) - strtotime($audioPl->assign_time)) + $audio->ag_work_time;
                elseif(\Auth::user()->type == 'SU')
                    $sp_work_time = (strtotime($currentTime) - strtotime($audioPl->assign_time)) + $audio->sp_work_time;

                $whereArr = [
                    'as_id' => $request->input('as_id'),
                    'callid' => $callid,
                    'segment_id' => $segmentId,
                    'party' => $party,
                    'brand_name' => $brandName
                ];
                $updateArr = [
                    'status' => config('dashboard_constant.AUDIO_STATUS.CROP'),
                    'sp_work_time' => $sp_work_time,
                    'ag_work_time' => $ag_work_time
                ];
                $logUpdateArr = [
                    'end_time' => $currentTime,
                    'audio_log_status' => config('dashboard_constant.AUDIO_STATUS.CROP'),
                    'agent_ht' => $agent_ht,
                    'audio_ht' => $audio_ht
                ];

                $updateRes = $this->updateCropSegment($whereArr, $updateArr, $logUpdateArr);
                if($updateRes['result'] == true){
                    $this->generateAudioCutLog($request->input(), $cmd, $output);
                    return $this->processServiceResponse(true, "Audio Crop Successfully!", $firstCreateSegment);
                }
                
            }
        }
        
        return $this->processServiceResponse(false, "Audio Crop Failed!", $request);

    }

    public function generateAudioCutLog($postData, $cmd, $output){
        $logFilePath = config('dashboard_constant.WAVECUT_LOG_PATH');
        $logFile = fopen($logFilePath, "a");
        $txt = date('Y-m-d H:i:s').'     '.$postData['as_id'].'     '.json_encode($postData)."\n".json_encode($cmd)."\n".json_encode($output)."\n";
        fwrite($logFile, $txt);
        fclose($logFile); 
    }

    public function getMaxSegmentDetail($callid, $party, $brandName){
        $data = AudioSegment::where('callid', $callid)
        ->where('party', $party)
        ->where('brand_name', $brandName)
        ->orderBy('segment_id','DESC')
        ->first();
        return $data;
    }
    /**
     * insert new segment data
     * @param $insData | array (insert data array)
     * @param $newSegmentId | int 
     */
    public function createCropSegment($insData, $newSegmentId){
        $dataObj = new AudioSegment;
        $dataObj->as_id = $this->genAsid();
        $dataObj->callid = $insData['callid'];
        $dataObj->segment_id = $newSegmentId;
        $dataObj->brand_name = $insData['brand_name'];
        $dataObj->party = $insData['party'];
        $dataObj->user_id = (\Auth::user()->type == 'AG') ? Auth::user()->username : ($insData['user_id'] ? $insData['user_id'] : "");
        $dataObj->supervisor_id = (\Auth::user()->type == 'SU') ? Auth::user()->username : ($insData['supervisor_id'] ? $insData['supervisor_id'] : "");
        $dataObj->tester_id = (\Auth::user()->type == 'QA') ? Auth::user()->username : ($insData['tester_id'] ? $insData['tester_id'] : "");
        $dataObj->audio_gender = $insData['audio_gender'] ? $insData['audio_gender'] : "";
        $dataObj->audio_emotion = $insData['audio_emotion'] ? $insData['audio_emotion'] : "";
        $dataObj->audio_duration = $insData['audio_duration'] ? $insData['audio_duration'] : "";
        $dataObj->text_bangla = $insData['text_bangla'] ? $insData['text_bangla'] : "";
        $dataObj->text_english = $insData['text_english'] ? $insData['text_english'] : "";

        if(\Auth::user()->type == 'AG'){
            $dataObj->status = config('dashboard_constant.AUDIO_STATUS.NEW');
        }elseif (\Auth::user()->type == 'SU') {
            $dataObj->status = config('dashboard_constant.AUDIO_STATUS.DRAFT');
        }

        $dataObj->created_at = date("Y-m-d H:i:s");
        $dataObj->assign_at = date("Y-m-d H:i:s");
        $dataObj->comment = $insData['comment'] ? $insData['comment'] : "";
        $dataObj->sp_comment = $insData['sp_comment'] ? $insData['sp_comment'] : "";
        $dataObj->audio_status = $insData['audio_status'] ? $insData['audio_status'] : "";
        $dataObj->audio_status_updated_at = date("Y-m-d H:i:s");
        $dataObj->sp_transcript_comment = $insData['sp_transcript_comment'] ? $insData['sp_transcript_comment'] : "";
        $dataObj->qa_spelling_comment = $insData['qa_spelling_comment'] ? $insData['qa_spelling_comment'] : "";
        $dataObj->ag_work_time = 0; //$insData['ag_work_time'] ? $insData['ag_work_time'] : "";
        $dataObj->sp_work_time = 0; //$insData['sp_work_time'] ? $insData['sp_work_time'] : "";
        $dataObj->qa_work_time = 0; //$insData['qa_work_time'] ? $insData['qa_work_time'] : "";
        $dataObj->tr_count = 0; //$insData['tr_count'] ? $insData['tr_count'] : "";
        $dataObj->sr_count = 0; //$insData['sr_count'] ? $insData['sr_count'] : "";
        $dataObj->wrong_word_count = 0; //$insData['wrong_word_count'] ? $insData['wrong_word_count'] : "";
        $dataObj->language_type = $insData['language_type'] ? $insData['language_type'] : "";
        $dataObj->audio_quality = $insData['audio_quality'] ? $insData['audio_quality'] : "";
        $dataObj->sp_assign_at = date("Y-m-d H:i:s");
        $dataObj->parent_as_id = $insData['as_id'];
        
        if($dataObj->save()) {
            $current_time = date("Y-m-d H:i:s");
            $AudioProcessLog = new AudioProcessLog();
            $AudioProcessLog->as_id = $dataObj->as_id;
            $AudioProcessLog->user_id = \Auth::user()->username;
            $AudioProcessLog->user_type = \Auth::user()->type;
            $AudioProcessLog->assign_time = $current_time;
            $AudioProcessLog->log_start_time = $current_time;
            $AudioProcessLog->save();
            return $this->processServiceResponse(true, "Crop Segment Added Successfully!",$dataObj);
        }
        return $this->processServiceResponse(false, "Crop Segment Added Failed!",$dataObj);
    }
    
    public function updateCropSegment($conditions, $updateData, $logUpdateArr){
        
        $result = AudioSegment::where($conditions)
                ->update($updateData);

        if($result) {            
            // $to = date("Y-m-d H:i:s");        
            // $from = date("Y-m-d H:i:s", strtotime('-24 hours', strtotime($to)));
            // $affectedRows = AudioProcessLog::whereBetween('log_start_time', [$from, $to])
            //     ->where('as_id', $conditions['as_id'])
            //     ->where('user_type', \Auth::user()->type)
            //     ->where('user_id', \Auth::user()->username)
            //     ->update($logUpdateArr);

            // $logUpdateArr = [
            //         'end_time' => $currentTime,
            //         'audio_log_status' => config('dashboard_constant.AUDIO_STATUS.CROP'),
            //         'agent_ht' => $agent_ht,
            //         'audio_ht' => $audio_ht
            //     ];

            $to = date("Y-m-d H:i:s");
            $from = date("Y-m-d H:i:s", strtotime('-24 hours', strtotime($to)));
            $sql = 'UPDATE audio_process_log SET ';
            $sql .= 'end_time="'.$logUpdateArr['end_time'].'", ';
            $sql .= 'audio_log_status="'.$logUpdateArr['audio_log_status'].'", ';
            $sql .= 'agent_ht="'.$logUpdateArr['agent_ht'].'", ';
            $sql .= 'audio_ht="'.$logUpdateArr['audio_ht'].'" ';
            $sql .= 'WHERE log_start_time BETWEEN :from AND :to AND ';
            $sql .= 'as_id = :as_id AND ';
            $sql .= 'user_id = :user_id ';
            $sql .= 'ORDER BY log_start_time desc limit 1';
            $updateConditions = [
                'from'       => $from,
                'to'         => $to,
                'as_id'      => $conditions['as_id'],
                'user_id'    => \Auth::user()->username
            ];
            $affectedRows = DB::update($sql, $updateConditions);

            return $this->processServiceResponse(true, "Crop Segment Update Successfully!",$updateData);
        }
        return $this->processServiceResponse(false, "Crop Segment Update Failed!",$updateData);
    }
    public function getCropAudio($asid)
    {      
        if(\Auth::user()->type == 'AG'){
            $data = AudioSegment::where("user_id", \Auth::user()->username)
                ->where("as_id", $asid)
                ->where("status", config('dashboard_constant.AUDIO_STATUS.NEW'))
                ->first();
        }elseif (\Auth::user()->type == 'SU') {
            $data = AudioSegment::where("supervisor_id", \Auth::user()->username)
                ->where("as_id", $asid)
                ->where("status", config('dashboard_constant.AUDIO_STATUS.DRAFT'))
                ->first();
        }        

        if ($data) {
            $data->file_path = 'api/get-audio-file/'.$data->as_id;
            
        }
        return $this->processServiceResponse(true, "Load crop audio successfully",$data);
        
    }

    public function getAudioProcessLog($asid){ 
        // DB::enableQueryLog();     
        // var_dump($asid);  
        $to = date("Y-m-d H:i:s");        
        $from = date("Y-m-d H:i:s", strtotime('-24 hours', strtotime($to)));
        $audioPl = AudioProcessLog::whereBetween('log_start_time', [$from, $to])
                    ->where('as_id', $asid)
                    ->where('user_type', \Auth::user()->type)
                    ->where('user_id', \Auth::user()->username)
                    ->orderBy('log_start_time', 'DESC')
                    ->first();
        // dd(DB::getQueryLog());

        return $audioPl;        
    }

    public function updateAgentWorkBeforeLogout($as_id) {
        $audioSegment = AudioSegment::where('as_id', $as_id)->first();

        if(!empty($audioSegment)){
            $audioProcessLog = $this->getAudioProcessLog($as_id);

            if($audioProcessLog->start_time == '0000-00-00 00:00:00'){
                $audioProcessLog->start_time = $audioProcessLog->assign_time;
            }

            $currentTime = date("Y-m-d H:i:s");
            $agent_ht = strtotime($currentTime) - strtotime($audioProcessLog->start_time);
            $audio_ht = strtotime($currentTime) - strtotime($audioProcessLog->assign_time);
            $ag_work_time = $audioSegment->ag_work_time;
            $sp_work_time = $audioSegment->sp_work_time;
            $update_segments_data = [];

            if(\Auth::user()->type == 'AG'){
                $update_segments_data['user_id'] = "";
                $update_segments_data['status'] = "N";
                $update_segments_data['assign_at'] = "0000-00-00 00:00:00";
                $ag_work_time = (strtotime($currentTime) - strtotime($audioProcessLog->assign_time)) + $ag_work_time;
                $update_segments_data['ag_work_time'] = $ag_work_time;
            }elseif(\Auth::user()->type == 'SU'){
                $update_segments_data['supervisor_id'] = "";
                $update_segments_data['status'] = "D";
                $update_segments_data['sp_assign_at'] = "0000-00-00 00:00:00";
                $sp_work_time = (strtotime($currentTime) - strtotime($audioProcessLog->assign_time)) + $sp_work_time;
                $update_segments_data['sp_work_time'] = $sp_work_time;
            }            
            $flagAudioSegment = AudioSegment::where('as_id', $as_id)
                                    ->update($update_segments_data);

            // DB::enableQueryLog();
            $to = date("Y-m-d H:i:s");
            $from = date("Y-m-d H:i:s", strtotime('-24 hours', strtotime($to)));
            $sql = 'UPDATE audio_process_log SET ';
            $sql .= 'start_time="'.$audioProcessLog->start_time.'", ';
            $sql .= 'end_time="'.$currentTime.'", ';
            $sql .= 'audio_log_status="O", ';
            $sql .= 'agent_ht="'.$agent_ht.'", ';
            $sql .= 'audio_ht="'.$audio_ht.'" ';
            $sql .= 'WHERE log_start_time BETWEEN :from AND :to AND ';
            $sql .= 'as_id = :as_id AND ';
            $sql .= 'user_id = :user_id ';
            $sql .= 'ORDER BY log_start_time desc limit 1';
            $updateConditions = [
                'from'       => $from,
                'to'         => $to,
                'as_id'      => $audioSegment->as_id,
                'user_id'    => \Auth::user()->username
            ];
            $flagAudioProcessLog = DB::update($sql, $updateConditions);
            // dd(DB::getQueryLog());
        }
    }

    public function createIdleLog() {
        $currentDate = date("Y-m-d H:i:s");
        $from = date("Y-m-d H:i:s", strtotime('-360 hours', strtotime($currentDate)));
        $as_id = AudioProcessLog::whereBetween('log_start_time', [$from, $currentDate])
                    ->where('user_id',\Auth::user()->username)
                    ->select('as_id')
                    ->orderBy('log_start_time', 'DESC')
                    ->first();
        if(!$as_id){
            $as_id = 'Null';
        }else{
            $as_id = $as_id->as_id;
        }
        $userSession = UserSession::where('user_id',\Auth::user()->username)->first();
        if(!$userSession){
            $userSession = new UserSession();
            $userSession->user_id       = \Auth::user()->username;
            $userSession->loginTime     = $currentDate;
            $userSession->idle          = 'O';
            $userSession->forceLogout   = 'I';
            $userSession->current_as_id = $as_id;
            $userSession->action        = 'UL';
            $userSession->save();
        }else{
            DB::table('user_session')->where("user_id", Auth::user()->username)
                ->update([
                    'loginTime' => $currentDate,
                    'idle' => 'O',
                    'forceLogout' => 'I',
                    'current_as_id' => $as_id,
                    'action' => 'UL'
                ]);
        }
        return true;
    }
    public function updateIdleLogout() {
        DB::table('user_session')->where("user_id", Auth::user()->username)
            ->update([
                'idle' => 'F',
                'forceLogout' => 'I',
                'action' => 'UO'
            ]);
    }
    public function updateforceLogout() {
        DB::table('user_session')->where("user_id", Auth::user()->username)
            ->update([
                'idle' => 'F',
                'forceLogout' => 'A',
                'action' => 'FO'
            ]);
    }
}
