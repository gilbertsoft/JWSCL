{
<B>Abstract</B>This unit hosts utilty functions.
@author(Christian Wimmer)
<B>Created:</B>03/23/2007 
<B>Last modification:</B>09/10/2007 

Project JEDI Windows Security Code Library (JWSCL)

The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License");
you may not use this file except in compliance with the License. You may obtain a copy of the
License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF
ANY KIND, either express or implied. See the License for the specific language governing rights
and limitations under the License.

Alternatively, the contents of this file may be used under the terms of the  
GNU Lesser General Public License (the  "LGPL License"), in which case the   
provisions of the LGPL License are applicable instead of those above.        
If you wish to allow use of your version of this file only under the terms   
of the LGPL License and not to allow others to use your version of this file 
under the MPL, indicate your decision by deleting  the provisions above and  
replace  them with the notice and other provisions required by the LGPL      
License.  If you do not delete the provisions above, a recipient may use     
your version of this file under either the MPL or the LGPL License.          
                                                                             
For more information about the LGPL: http://www.gnu.org/copyleft/lesser.html 

The Original Code is JwsclUtils.pas.

The Initial Developer of the Original Code is Christian Wimmer.
Portions created by Christian Wimmer are Copyright (C) Christian Wimmer. All rights reserved.

Description:
This unit hosts utility functions.
}
unit JwsclUtils;
{$I Jwscl.inc}
// Last modified: $Date: 2007-09-10 10:00:00 +0100 $


//Check for FastMM4
{$IFDEF FASTMM4}
  //and also activate debug mode (leak detection for Local-/GlobalAlloc)
  {$DEFINE FullDebugMode}
{$ENDIF FASTMM4}
{.$UNDEF FullDebugMode}

//check for Eurekalog
{$IFDEF EUREKALOG}
  {$DEFINE FullDebugMode}
{to see if this memory manager catches Local/Global leaks}  
  {.$UNDEF FASTMM4}
  {.$UNDEF MEMCHECK}
  {.$UNDEF FullDebugMode}
{$ENDIF EUREKALOG}

interface

uses
  Classes,
  jwaWindows,
{$IFDEF JCL}
  JclWideFormat,
  JclWideStrings,
{$ENDIF}
  JwsclTypes,
  JwsclExceptions,
  JwsclResource,
  //JwsclDescriptor, //do not set!
  JwsclStrings;



type
  {<B>TJwThread</B> defines a thread base class
  which offers a name for the thread.
  Override Execute and call it at first
  to have any effect.
  }
  TJwThread = class(TThread)
  private
    { Private declarations }
    FName: AnsiString;

    procedure SetName(const Name: AnsiString);
  protected
    FTerminatedEvent: THandle;
  public
    {<B>Execute</B> is the main execution procedure of thread.
     Override it and call it at first.
    }
    procedure Execute; override;
  public
    {<B>Create</B> create a thread instance.
     @param CreateSuspended defines whether the thread is created
      and commenced immediately (false) or suspended (true). 
     @param Name defines the thread's name 
     }
    constructor Create(const CreateSuspended: Boolean; const Name: AnsiString);
    destructor Destroy; override;

    function WaitWithTimeOut(const TimeOut: DWORD) : LongWord;

    {<B>Name</B> sets or gets the threads name.
     The name is retrieved from internal variable. Changing the thread's name
     using foreign code does not affect this property.
    }
    property Name: AnsiString read FName write SetName;


  end;

  TJwIntTupleList = class
  private
    procedure Delete(Index: DWORD);
  protected
    fList : TList;
    function GetItem(Index : DWORD) : Pointer;
    procedure SetItem(Index : DWORD; Value : Pointer);
    function GetCount : Cardinal;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(Index : DWORD; Value : Pointer);
    procedure DeleteIndex(Index : DWORD);

    property Items[Index : DWORD] : Pointer read GetItem write SetItem; default;
    property Count : Cardinal read GetCount;
  end;

{<B>JwGlobalFreeAndNil</B> calls GlobalFree on parameter hMem and sets it to zero (0).}
procedure JwGlobalFreeAndNil(var hMem: HGLOBAL);

{<B>JwLocalAllocMem</B> creates a managed memory handle by LocalAlloc.
Some memory leak managers do not recognize leaks created by
LocalAlloc and GlobalAlloc. Thus we create for them a GetMem
memory block.
Replace each call to LocalAlloc/GlobalAlloc with JwLocalAllocMem/JwGlobalAllocMem
and their counter parts JwLocalFreeMem/JwGlobalFreeMem.
If a counter part is not called and the program halts the memory manager
will (hopefully) show the stack trace to the GetMemPointer created by
JwLocalAllocMem/JwGlobalAllocMem.

Warning: Do not call JwLocalAllocMem/JwGlobalAllocMem for API functions
that will free the handle. GetMemPointer will remain
whatsoever. Instead use LocalAlloc/GlobalAlloc.
This behavior is rare but the API documentation will (mostly) say it.
Refer to MSDN documentation for more information.}
function JwLocalAllocMem(uFlags: UINT; uBytes: SIZE_T): HLOCAL;

{<B>JwLocalFreeMem</B> frees a managed LocalAlloc handle created by JwLocalAllocMem.
The given handle will be set to 0.
Refer to MSDN documentation for more information.
raises
 EInvalidPointer:  if the given handle was not created by JwLocalAllocMem .}
function JwLocalFreeMem(var hMem: HLOCAL): HLOCAL;

{<B>JwGlobalAllocMem</B> creates a managed memory handle by LocalAlloc.
Some memory leak managers do not recognize leaks created by
LocalAlloc and GlobalAlloc. Thus we create for them a GetMem
memory block.
Replace each call to LocalAlloc/GlobalAlloc with JwLocalAllocMem/JwGlobalAllocMem
and their counter parts JwLocalFreeMem/JwGlobalFreeMem.
If a counter part is not called and the program halts the memory manager
will (hopefully) show the stack trace to the GetMemPointer created by
JwLocalAllocMem/JwGlobalAllocMem.

Warning: Do not call JwLocalAllocMem/JwGlobalAllocMem for API functions
that will free the handle. GetMemPointer will remain
whatsoever. Instead use LocalAlloc/GlobalAlloc.
This behavior is rare but the API documentation will (mostly) say it.
Refer to MSDN documentation for more information.}
function JwGlobalAllocMem(uFlags: UINT; uBytes: SIZE_T): HGLOBAL;

{<B>JwGlobalFreeMem</B> frees a managed GlobalAlloc handle created by JwGlobalAllocMem.
The given handle will be set to 0.
Refer to MSDN documentation for more information.
raises
 EInvalidPointer:  if the given handle was not created by JwGlobalAllocMem.}
function JwGlobalFreeMem(var hMem: HGLOBAL): HGLOBAL;





{<B>LocalizeMapping</B> loads the resource strings of a TJwRightsMapping record array
defined in JwsclTypes.pas.
To convert a rights mapping record array define a start resource string
index, say 4000. This is the starting point of the resource strings, but
it does not define a string. It simply contains a number that defines the count
of array elements, say 4.
So the record array must look like this :
<code lang="Delphi">
  MyMapping: array[1..4] of TJwRightsMapping =
    (
    (Right: STANDARD_RIGHTS_ALL; Name: 'STANDARD_RIGHTS_ALL';
    Flags: 0; StringId : 5008),
    (Right: STANDARD_RIGHTS_READ; Name: 'STANDARD_RIGHTS_READ';
    Flags: 0),
    (Right: STANDARD_RIGHTS_WRITE; Name: 'STANDARD_RIGHTS_WRITE';
    Flags: 0),
    (Right: STANDARD_RIGHTS_EXECUTE; Name: 'STANDARD_RIGHTS_EXECUTE';
    Flags: 0));
</code>
Each element is linked to the resource string. e.g.
 MyMapping[1].Name is read from string resource with index [4001]
 MyMapping[2].Name is read from string resource with index [4002] and so on.
So the last index of the array (here 4) is resource index [4004].

There is the possibility to use exceptional indexes. To do so set StringId
member of the TJwRightsMapping to an index which starts at "StartStringId".
The positive number will be increased by the parameter StartStringId to
get the resource string index.
E.g. set StringId to 20 to load the resource string from index [4020] (=
<StartStringId> + 20)
It is also possible to use absolute values - like 4020. To use them
simply negate the StringId. e.g. StringID: "-4020" will load index [4020].
It is discouraged to use absolute values because they do not depend on the
parameter StartStringId. Changing this value and the resource strings
will lead to EJwsclResourceNotFound exception.

@param MappingRecord @italic([in,out]) receives an array of TJwRightsMapping which
  string member Name is replaced by the resource string. 

@param StartStringId defines the starting position of the index counting.
 It must be an absolute resource string index, which context contains a number
 that defines the count of array elements. 

@param PrimaryLanguageId defines the primary language id.
use PRIMARYLANGID(GetUserDefaultUILanguage), SUBLANGID(GetUserDefaultUILanguage)
to get user language. 

@param SubLanguageId defines the sub language id. 

@param UseDefaultOnError defines whether EJwsclResourceNotFound is thrown if a
resource index is invalid (could not be found in resource) (false) or not (true).
If UseDefaultOnError is true the function does the following.

1. Try to load resource string at index given by member StringId 
2. if fails : try to load resource string ignoring member StringId 
3. if fails : leave the text member Name to default value 
 

@param ModuleInstance defines where the resource strings can be found. It is simply
put through to LoadString function. It can be an instance of a dll file which
contains localized versions of the strings. 

raises
 EJwsclResourceInitFailed:  is raised if the given value in parameter
StartStringId could not be found in the string resource 

 EJwsclResourceUnequalCount: is raised if the count of the members of
the given array (MappingRecord) is not equal to the number given in the resource
string at index StartStringId. 

 EJwsclResourceNotFound: is raised if UseDefaultOnError is false and
a given resource index of a member of the array of TJwRightsMapping could not
be found }
procedure LocalizeMapping(var MappingRecord : array of TJwRightsMapping;
  const StartStringId : Cardinal;
  const PrimaryLanguageId, SubLanguageId : Word;
  const UseDefaultOnError : Boolean = true;
  ModuleInstance : HINST = 0
  );

{<B>JwCheckArray</B> checks whether a object type list array is correctly formed.
The array must be in a post fix order. This sequence describes the
Level structure.

<pre>
Objs[i .Level = a_i
        { a_i +1        | a_i - a_(i-1) = 1 AND a_i < 4
a_i+1 = { a_i - t       | a_i - t AND t >= 0
        { ERROR_INVALID_PARAMETER | else
</pre> 

sequence start: a_0 = 0

@param Objs contains the object list 
@return Returns true if the object type list is correct; otherwise false.
      It returns false if Objs is nil or does not contain any element.
      It also returns false if any GUID member is nil. 
}
function JwCheckArray(const Objs : TJwObjectTypeArray) : Boolean; overload;

{<B>JwCheckArray</B> checks whether a object type list array is correctly formed.
The array must be in a post fix order. This sequence describes the
Level structure.

<pre>
Objs[i .Level = a_i
        { a_i +1        | a_i - a_(i-1) = 1 AND a_i < 4
a_i+1 = { a_i - t       | a_i - t AND t >= 0
        { ERROR_INVALID_PARAMETER | else
</pre> 

sequence start: a_0 = 0

@param Objs contains the object list 
@param Index returns the index where an error occured. 
@return Returns true if the object type list is correct; otherwise false.
      It returns false if Objs is nil or does not contain any element.
      It also returns false if any GUID member is nil. 
}
function JwCheckArray(const Objs : TJwObjectTypeArray; out Index : Integer) : Boolean; overload;

{<B>JwUNIMPLEMENTED_DEBUG</B> raises exception EJwsclUnimplemented if compiler directive DEBUG
was used to compile the source}
procedure JwUNIMPLEMENTED_DEBUG;

{<B>JwUNIMPLEMENTED</B> raises exception EJwsclUnimplemented}
procedure JwUNIMPLEMENTED;

{<B>JwRaiseOnNilMemoryBlock</B> raises an exception EJwsclNilPointer if parameter P
 is nil; otherwise nothing happens.
This function is like Assert but it will not be removed in a release build.

@param P defines a pointer to be validated 
@param ParameterName defines the name of the parameter which is validated and
 belongs to this pointer 
@param MethodName defines the name of the method this parameter belongs to 
@param ClassName defines the name of the class the method belongs to. Can be
  empty if the method does not belong to a class 
@param FileName defines the source file of the call to this procedure. 

raises
 EJwsclNilPointer:  will be raised if P is nil 
}
procedure JwRaiseOnNilMemoryBlock(const P : Pointer;
  const MethodName, ClassName, FileName : TJwString);

{<B>JwRaiseOnNilParameter</B> raises an exception EJwsclNILParameterException if parameter P
 is nil; otherwise nothing happens.
This function is like Assert but it will not be removed in a release build.

@param P defines a pointer to be validated
@param ParameterName defines the name of the parameter which is validated and
 belongs to this pointer
@param MethodName defines the name of the method this parameter belongs to
@param ClassName defines the name of the class the method belongs to. Can be
  empty if the method does not belong to a class
@param FileName defines the source file of the call to this procedure.

raises
 EJwsclNILParameterException:  will be raised if P is nil
}
procedure JwRaiseOnNilParameter(const P : Pointer;
  const ParameterName, MethodName, ClassName, FileName : TJwString);

{<B>JwRaiseOnClassTypeMisMatch</B> raises an exception EJwsclClassTypeMismatch if parameter Instance
 is not of type ExpectedClass.
This function is like Assert but it will not be removed in a release build.

@param Instance defines the class to be tested. If this parameter is nil, the procedure exists without harm.
@param ExpectedClass defines the class type to be checked for.
@param MethodName defines the name of the method this parameter belongs to
@param ClassName defines the name of the class the method belongs to. Can be
  empty if the method does not belong to a class
@param FileName defines the source file of the call to this procedure.

raises
 EJwsclNILParameterException:  will be raised if P is nil
}
procedure JwRaiseOnClassTypeMisMatch(const Instance : TObject;
  const ExpectedClass : TClass;
  const MethodName, ClassName, FileName : TJwString);

{$IFDEF JW_TYPEINFO}
function GetUnitName(argObject: TObject): AnsiString;
{$ENDIF JW_TYPEINFO}

{<B>JwSetThreadName</B> names a thread. A debugger can use this name to display a human readably
identifier for a thread.
<B>JwSetThreadName</B> must be called without using parameter ThreadID
 as a precondition to use JwGetThreadName .

@param Name defines an ansi name for the thread 
@param ThreadID defines which thread is named. A value of Cardinal(-1)  uses
  the current thread 
}
procedure JwSetThreadName(const Name: AnsiString; const ThreadID : Cardinal = Cardinal(-1));

{<B>JwGetThreadName</B> returns the name of a thread set by JwSetThreadName.
 This function only returns the name of the current thread. It cannot be used
 with different threads than the current one.

<B>Precondition:</B> 
 JwSetThreadName must be called with a value of Cardinal(-1) for parameter ThreadID.
}
function JwGetThreadName : WideString;

{<B>IsHandleValid</B> returns true if Handle is neither zero (0) nor INVALID_HANDLE_VALUE; otherwise false.}
function JwIsHandleValid(const Handle : THandle) : Boolean;

{<B>JwCheckBitMask</B> Checks if Bitmask and Check = Check}
function JwCheckBitMask(const Bitmask: Integer; const Check: Integer): Boolean; 

{<B>JwMsgWaitForMultipleObjects</B> encapsulates MsgWaitForMultipleObjects using an open array
parameter.}
function JwMsgWaitForMultipleObjects(const Handles: array of THandle; bWaitAll: LongBool;
           dwMilliseconds: DWord; dwWakeMask: DWord): DWord;

function JwWaitForMultipleObjects(const Handles: array of THandle; bWaitAll: LongBool;
           dwMilliseconds: DWord): DWord;


{<B>JwCreateWaitableTimer</B> creates a waitable time handle.

@param TimeOut defines a signal interval in miliseconds (1sec = 1000msec)
@param SecurityAttributes defines security attributes for the timer. The class type
  must be TJwSecurityDescriptor or a derivation.
@return Returns a handle to the new timer object. Must be closed by CloseHandle.

raise
  EJwsclClassTypeMismatch: If parameter SecurityAttributes is not nil and also
    not of the type TJwSecurityDescriptor, an exception EJwsclClassTypeMismatch is raised.
  EOSError: If any winapi calls fail, an exception EJwsclWinCallFailedException is raised.
}
function JwCreateWaitableTimer(
      const TimeOut: DWORD;
      const SecurityAttributes : TObject = nil) : THandle; overload;

{<B>JwCreateWaitableTimer</B> creates a waitable time handle.

For more information about the undocumented parameters, see MSDN
  http://msdn.microsoft.com/en-us/library/ms686289(VS.85).aspx

This function does not support absolute time like the original winapi function.
It means that you cannot specify a point in time.

@param TimeOut defines a signal interval in miliseconds (1sec = 1000msec)
@param Name defines a name for the timer. If Name is empty, the timer will be unnamed.
@param SecurityAttributes defines security attributes for the timer. The class type
  must be TJwSecurityDescriptor or a derivation.

@return Returns a handle to the new timer object. Must be closed by CloseHandle.

raise
  EJwsclClassTypeMismatch: If parameter SecurityAttributes is not nil and also
    not of the type TJwSecurityDescriptor, an exception EJwsclClassTypeMismatch is raised.
  EOSError: If any winapi calls fail, an exception EJwsclWinCallFailedException is raised.
}
function JwCreateWaitableTimer(
      const TimeOut: DWORD;
      const ManualReset : Boolean;
      const Name : TJwString;
      const Period : Integer = 0;
      const CompletitionRoutine : PTIMERAPCROUTINE = nil;
      const CompletitionRoutineArgs : Pointer = nil;
      const SuspendResume : Boolean = false;
      const SecurityAttributes : TObject = nil) : THandle; overload;

implementation
uses SysUtils, JwsclToken, JwsclKnownSid, JwsclDescriptor, JwsclAcl,
     JwsclSecureObjects, JwsclMapping
{$IFDEF JW_TYPEINFO}
     ,TypInfo
{$ENDIF JW_TYPEINFO}
     ;

{$IFDEF JW_TYPEINFO}
function GetUnitName(argObject: TObject): AnsiString;
var
  ptrTypeData: PTypeData;
begin
  if (argObject.ClassInfo <> nil) then
  begin
    ptrTypeData := GetTypeData(argObject.ClassInfo);
    Result := ptrTypeData.UnitName;
  end;
end;
{$ENDIF JW_TYPEINFO}


function JwIsHandleValid(const Handle : THandle) : Boolean;
begin
  result := (Handle <> 0) and (Handle <> INVALID_HANDLE_VALUE);
end;

function JwCheckBitMask(const Bitmask: Integer; const Check: Integer): Boolean;
begin
  Result := BitMask and Check = Check;
end;

type
  TThreadNameInfo = record
    FType: LongWord;     // must be 0x1000
    FName: PAnsiChar;        // pointer to name (in user address space)
    FThreadID: LongWord; // thread ID (-1 indicates caller thread)
    FFlags: LongWord;    // reserved for future use, must be zero
  end;


procedure TJwThread.SetName(const Name: AnsiString);
begin
  FName := Name;
  JwSetThreadName(Name, ThreadID);
end;

constructor TJwThread.Create(const CreateSuspended: Boolean; const Name: AnsiString);
begin
  inherited Create(CreateSuspended);

  SetName(Name);

  FTerminatedEvent := CreateEvent(nil, False, False, nil);
end;

destructor TJwThread.Destroy;
begin
  CloseHandle(FTerminatedEvent);
  inherited;
end;


procedure TJwThread.Execute;
begin
  SetName(Name);
end;

threadvar InternalThreadName : WideString;

function JwGetThreadName : WideString;
begin
  result := InternalThreadName;
end;

//source http://msdn2.microsoft.com/en-us/library/xcb2z8hs(vs.71).aspx
procedure JwSetThreadName(const Name: AnsiString; const ThreadID : Cardinal = Cardinal(-1));
{$IFDEF MSWINDOWS}
var
  ThreadNameInfo: TThreadNameInfo;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  ThreadNameInfo.FType := $1000;
  ThreadNameInfo.FName := PAnsiChar(AnsiString(Name));
  if (ThreadID = Cardinal(-1)) or (ThreadID = GetCurrentThreadID) then
    InternalThreadName := WideString(Name);

  ThreadNameInfo.FThreadID := ThreadID; //$FFFFFFFF;
  ThreadNameInfo.FFlags := 0;

  try
    RaiseException( $406D1388, 0, SizeOf(ThreadNameInfo) div SizeOf(LongWord),
      @ThreadNameInfo );
  except
  end;
{$ENDIF}
end;


procedure JwRaiseOnNilParameter(const P : Pointer; const ParameterName, MethodName, ClassName, FileName : TJwString);
begin
  if not Assigned(P) then
  raise EJwsclNILParameterException.CreateFmtEx(
      RsNilParameter, MethodName,
      ClassName, FileName, 0, False, [ParameterName]);
end;

procedure JwRaiseOnNilMemoryBlock(const P : Pointer; const MethodName, ClassName, FileName : TJwString);
begin
  if P = nil then
    raise EJwsclNilPointer.CreateFmtEx(
     RsNilPointer,
      MethodName, ClassName, FileName, 0, false, []);
end;

procedure JwRaiseOnClassTypeMisMatch(const Instance : TObject;
  const ExpectedClass : TClass;
  const MethodName, ClassName, FileName : TJwString);
begin
  if Assigned(Instance) and
    not (Instance is TJwSecurityDescriptor) then
      raise EJwsclClassTypeMismatch.CreateFmtEx(
               RsInvalidClassType,
               MethodName, ClassName, FileName, 0, false,
                [Instance.ClassName, ExpectedClass.ClassName]);
end;

function JwCheckArray(const Objs : TJwObjectTypeArray; out Index : Integer) : Boolean;
var
    LastLevel : Cardinal;
begin
  Index := 0;

  result := Assigned(Objs);
  if not result then exit;

  result := Length(Objs) > 0;
  if not result then exit;

  result := Objs[0].Level = 0;
  if not result then exit;

  LastLevel := 0;
  if Length(Objs) > 1 then
  begin
    Index := 1;
    while Index <= high(Objs) do
    begin
      result := (Objs[Index].Level > 0) and (Objs[Index].Level < 5);
      if not result then exit;

      if Objs[Index].Level > LastLevel then
      begin
        result := (Objs[Index].Level - LastLevel) = 1;
        if not result then exit;
      end;

      if Objs[Index].ObjectType = nil then
        exit;

      LastLevel := Objs[Index].Level;
      Inc(Index);
    end;
  end;
end;

function JwCheckArray(const Objs : TJwObjectTypeArray) : Boolean;
var Index : Integer;
begin
  result := JwCheckArray(Objs, Index);
end;

procedure JwUNIMPLEMENTED;
begin
  raise EJwsclUnimplemented.CreateFmtEx(
    'This function is not implemented.',
    '', '', '', 0, false, []);
end;

procedure JwUNIMPLEMENTED_DEBUG;
begin
{$IFNDEF DEBUG}
  raise EJwsclUnimplemented.CreateFmtEx(
    'This function is not implemented.',
    '', '', '', 0, false, []);
{$ENDIF DEBUG}    
end;

procedure LocalizeMapping(var MappingRecord : array of TJwRightsMapping;
  const StartStringId : Cardinal;
  const PrimaryLanguageId, SubLanguageId : Word;
  const UseDefaultOnError : Boolean = true;
  ModuleInstance : HINST = 0
  );
var ArrayHi,ArrayLo : Cardinal;
    LHi : Cardinal;
    i,
    Id : Integer;
    bSuccess : Boolean;
    S : TJwString;

  function GetNumber(S : TJwString) : Cardinal;
  var i : Integer;
  begin
    for i := 1 to Length(S) do
    begin
      //if not ((S[i] >= '0') and (S[i] <= '9')) then
      if not (S[i] in [TJwChar('0')..TJwChar('9')]) then
      begin
        SetLength(S, i-1);
        break;
      end;
    end;
    result := StrToIntDef(S,0);
  end;
begin
  ArrayHi := high(MappingRecord);
  ArrayLo := low(MappingRecord);

  if ModuleInstance = 0 then
    ModuleInstance := HInstance;


  try
    S := LoadLocalizedString(StartStringId, PrimaryLanguageId, SubLanguageId, ModuleInstance);
  except
     on E : EJwsclOSError do
       raise EJwsclResourceInitFailed.CreateFmtEx(
               RsResourceInitFailed,
               'LocalizeMapping', '', RsUNUtils, 0, true,
                [StartStringID]);
  end;

  {Load last string number and compare it to the highest one
   of the given array. If unequal we have a problem.}
  LHi := GetNumber(S);
  if (LHi < ArrayHi+1) then
    raise EJwsclResourceUnequalCount.CreateFmtEx(
            RsResourceUnequalCount,
            'LocalizeMapping', '', RsUNUtils, 0, false, [LHi,StartStringID,ArrayHi]);


  for i := ArrayLo to ArrayHi do
  begin
    bSuccess := true;
    
    if MappingRecord[i].StringId > 0 then
    begin
      Id := MappingRecord[i].StringId;
      Inc(Id, StartStringID);
    end
    else
    if MappingRecord[i].StringId < 0 then
      Id := (-MappingRecord[i].StringId)
    else
    begin
      Id := i;
      Inc(Id);
      Inc(Id, StartStringID);
    end;


    try
      S := LoadLocalizedString(Id, PrimaryLanguageId, SubLanguageId, ModuleInstance);
    except
      on E : EJwsclOSError do
      begin
        if UseDefaultOnError then
        begin
          Id := i;
          Inc(Id);
          Inc(Id, StartStringID);
        end;

        try
          S := LoadLocalizedString(Id, PrimaryLanguageId, SubLanguageId, ModuleInstance);
        except
          on E : EJwsclOSError do
          begin
            if UseDefaultOnError then
              bSuccess := false
            else
              raise EJwsclResourceNotFound.CreateFmtEx(
                RsResourceNotFound,
                'LocalizeMapping', '', RsUNUtils, 0, true, [Id]);
          end;
        end; //try except
      end;
    end; //try except

    if bSuccess then
      MappingRecord[i].Name := S;
  end;
end;

function JwMsgWaitForMultipleObjects(const Handles: array of THandle; bWaitAll: LongBool;
           dwMilliseconds: DWord; dwWakeMask: DWord): DWord;
begin
  Result := MsgWaitForMultipleObjects(Length(Handles), @Handles[0], bWaitAll, dwMilliseconds, dwWakeMask);
end;

function JwWaitForMultipleObjects(const Handles: array of THandle; bWaitAll: LongBool;
           dwMilliseconds: DWord): DWord;
begin
  Result := WaitForMultipleObjects(Length(Handles), @Handles[0], bWaitAll, dwMilliseconds);
end;


{$IFDEF FullDebugMode}
type
     PMemTuple = ^TMemTuple;
     TMemTuple = record
       GetMemPointer : Pointer;
       case MemType : Boolean of
         true : (LocalData : HLOCAL);              
         false: (GlobalData : HGLOBAL);
      end;
var InternalMemArray : TList {=nil};
{$ENDIF}


function JwLocalAllocMem(uFlags: UINT; uBytes: SIZE_T): HLOCAL;
{$IFDEF FullDebugMode}
var MemTuple : PMemTuple;
{$ENDIF FullDebugMode}
begin
  result := LocalAlloc(uFlags,uBytes);
{$IFDEF FullDebugMode}
  if result <> 0 then
  begin
    New(MemTuple);
    GetMem(MemTuple.GetMemPointer,uBytes);
    MemTuple.MemType := true;
    MemTuple.LocalData := result;
    InternalMemArray.Add(MemTuple);
  end;
{$ENDIF}
end;

function JwLocalFreeMem(var hMem: HLOCAL): HLOCAL;
{$IFDEF FullDebugMode}
  function Find : Integer;
  var i : Integer;
  begin
    result := -1;
    for I := 0 to InternalMemArray.Count - 1 do
    begin
      if PMemTuple(InternalMemArray[i]).MemType and
         (PMemTuple(InternalMemArray[i]).LocalData = hMem) then
      begin
        result := i;
        exit;
      end;
    end;
  end;
{$ENDIF}

{$IFDEF FullDebugMode}
var Index : Integer;
{$ENDIF FullDebugMode}

begin
{$IFDEF FullDebugMode}
  if LocalLock(hMem) <> nil then
  begin
    Index := Find;
    if Index < 0 then
    begin
      LocalUnlock(hMem);
      raise EInvalidPointer.Create(RsInvalidLocalPointer);
    end;

    FreeMem(PMemTuple(InternalMemArray[Index]).GetMemPointer);
    FreeMem(PMemTuple(InternalMemArray[Index]));
    InternalMemArray.Delete(Index);

    LocalUnlock(hMem);
{$ENDIF FullDebugMode}
    result := LocalFree(hMem);
{$IFDEF FullDebugMode}
  end;
{$ENDIF FullDebugMode}
  hMem := 0;
end;




function JwGlobalAllocMem(uFlags: UINT; uBytes: SIZE_T): HGLOBAL;
{$IFDEF FullDebugMode}
var MemTuple : PMemTuple;
{$ENDIF FullDebugMode}
begin
  result := GlobalAlloc(uFlags,uBytes);
{$IFDEF FullDebugMode}
  if result <> 0 then
  begin
    New(MemTuple);
    GetMem(MemTuple.GetMemPointer,uBytes);
    MemTuple.MemType := false;
    MemTuple.GlobalData := result;
    InternalMemArray.Add(MemTuple);
  end;
{$ENDIF FullDebugMode}
end;

function JwGlobalFreeMem(var hMem: HGLOBAL): HGLOBAL;
{$IFDEF FullDebugMode}
  function Find : Integer;
  var i : Integer;
  begin
    result := -1;
    i := -1;
    for I := 0 to InternalMemArray.Count - 1 do
    begin
      if not PMemTuple(InternalMemArray[i]).MemType and
         (PMemTuple(InternalMemArray[i]).GlobalData = hMem) then
      begin
        result := i;
        exit;
      end;
    end;
  end;
{$ENDIF FullDebugMode}

{$IFDEF FullDebugMode}
var Index : Integer;
{$ENDIF FullDebugMode}
begin
  result := 0;
{$IFDEF FullDebugMode}
  if GlobalLock(hMem) <> nil then
  begin
    Index := Find;
    if Index < 0 then
    begin
      GlobalUnlock(hMem);
      raise EInvalidPointer.Create(RsInvalidGlobalPointer);
    end;

    FreeMem(PMemTuple(InternalMemArray[Index]).GetMemPointer);
    FreeMem(PMemTuple(InternalMemArray[Index]));
    InternalMemArray.Delete(Index);

    GlobalUnlock(hMem);
{$ENDIF FullDebugMode}

    result := GlobalFree(hMem);
{$IFDEF FullDebugMode}
  end;
{$ENDIF FullDebugMode}
  hMem := 0;
end;


procedure JwGlobalFreeAndNil(var hMem: HGLOBAL);
begin
  if hMem <> 0 then
    GlobalFree(hMem);
  hMem := 0;
end;


{$IFDEF FullDebugMode}
procedure DeleteInternalMemArray;
var i : Integer;
begin
  //we do not attempt to free the remaining TMemTuple.GetMemPointer blocks
  //instead we only remove PMemTuple memory
  for i := 0 to InternalMemArray.Count-1 do
  begin
    FreeMem(PMemTuple(InternalMemArray[i]));
    InternalMemArray[i] := nil;
  end;
  FreeAndNil(InternalMemArray);
end;
{$ENDIF}


{var S : TJwString;
    SA : TResourceTStringArray;
    Indexes : TResourceIndexArray;
    i : Integer;     }



{ TJwIntTupleList }

type
  PIntTuple = ^TIntTuple;
  TIntTuple = record
    Index : DWORD;
    Value : Pointer;
  end;

procedure TJwIntTupleList.Add(Index : DWORD; Value: Pointer);
var P : PIntTuple;
begin
  new(P);
  P^.Index := Index;
  P^.Value := Value;
  fList.Add(P);
end;

constructor TJwIntTupleList.Create;
begin
  fList := TList.Create;
end;

procedure TJwIntTupleList.Delete(Index: DWORD);
var i : Integer;
begin
  for i := 0 to fList.Count - 1 do
  begin
    if PIntTuple(fList[i])^.Index = Index then
    begin
      Dispose(PIntTuple(fList[i]));

      fList.Delete(i);
      exit;
    end;
  end;

  raise ERangeError.CreateFmt('Index value %d not found',[Index]);
end;


procedure TJwIntTupleList.DeleteIndex(Index: DWORD);
var i : Integer;
begin
  for i := 0 to fList.Count - 1 do
  begin
    if PIntTuple(fList[i])^.Index = Index then
    begin
      dispose(PIntTuple(fList[i]));
      exit;
    end;
  end;

  raise ERangeError.CreateFmt('Value %d not found',[Index]);
end;


destructor TJwIntTupleList.Destroy;
begin
  FreeAndNil(fList);
  inherited;
end;

function TJwIntTupleList.GetCount: Cardinal;
begin
  result := fList.Count;
end;

function TJwIntTupleList.GetItem(Index: DWORD): Pointer;
var i : Integer;
begin
  for i := 0 to fList.Count - 1 do
  begin
    if PIntTuple(fList[i])^.Index = Index then
    begin
      result := PIntTuple(fList[i])^.Value;
      exit;
    end;
  end;

  raise ERangeError.CreateFmt('Value %d not found',[Index]);
end;

procedure TJwIntTupleList.SetItem(Index : DWORD; Value: Pointer);
var i : Integer;
begin
  for i := 0 to fList.Count - 1 do
  begin
    if PIntTuple(fList[i])^.Index = Index then
    begin
      PIntTuple(fList[i])^.Value := Value;
      exit;
    end;
  end;

  raise ERangeError.CreateFmt('Value %d not found',[Index]);
end;

function JwCreateWaitableTimer(
      const TimeOut: DWORD;
      const SecurityAttributes : TObject = nil) : THandle;
begin
  result := JwCreateWaitableTimer(TimeOut, false, '',0,nil,nil,false,SecurityAttributes);
end;



function JwCreateWaitableTimer(
      const TimeOut: DWORD;
      const ManualReset : Boolean;
      const Name : TJwString;
      const Period : Integer = 0;
      const CompletitionRoutine : PTIMERAPCROUTINE = nil;
      const CompletitionRoutineArgs : Pointer = nil;
      const SuspendResume : Boolean = false;
      const SecurityAttributes : TObject = nil) : THandle;
var
  TimeOutInt64 : LARGE_INTEGER;
  SA : PSecurityAttributes;
  pName : TJwPChar;
begin
  JwRaiseOnClassTypeMisMatch(SecurityAttributes, TJwSecurityDescriptor,
    'JwCreateWaitableTimer','',RsUNUtils);
  try
    SA := nil;
    if Assigned(SecurityAttributes) then
      SA := TJwSecurityDescriptor(SecurityAttributes).Create_SA();

    if Length(Name) > 0 then
      pName := TJwPchar(Name)
    else
      pName := nil;

    Result := {$IFDEF UNICODE}CreateWaitableTimerW{$ELSE}CreateWaitableTimerA{$ENDIF}
      (LPSECURITY_ATTRIBUTES(SA), ManualReset, pName);
    if (Result = 0) or (Result = INVALID_HANDLE_VALUE) then
      raise EJwsclWinCallFailedException.CreateFmtEx(
        RsWinCallFailed,
         'JwCreateWaitableTimer', '', RsUNUtils, 0, True, ['CreateWaitableTimer']);
  finally
    if SA <> nil then
      TJwSecurityDescriptor.Free_SA(SA);
  end;

  ZeroMemory(@TimeOutInt64,sizeof(TimeOutInt64));
  TimeOutInt64.HighPart := -1;
  TimeOutInt64.LowPart := (- Timeout * 10000) shr 32;


  if not SetWaitableTimer(Result, TimeOutInt64, Period, CompletitionRoutine, CompletitionRoutineArgs, SuspendResume) then
  begin
    CloseHandle(Result);
    raise EJwsclWinCallFailedException.CreateFmtEx(
        RsWinCallFailed,
         'JwCreateWaitableTimer', '', RsUNUtils, 0, True, ['SetWaitableTimer']);
  end;
end;


function TJwThread.WaitWithTimeOut(const TimeOut: DWORD) : LongWord;
var
  WaitResult: Cardinal;
  Msg: TMsg;
  hTimer : THandle;
begin
  if (TimeOut = 0) or (TimeOut = INFINITE) then
    result := WaitFor
  else
  if GetCurrentThreadID = MainThreadID then
  begin
    WaitResult := 0;

    hTimer := JwCreateWaitableTimer(TimeOut, true, '');
    try
      repeat
        { This prevents a potential deadlock if the background thread
          does a SendMessage to the foreground thread }
        if WaitResult = WAIT_OBJECT_0 + 2 then
          PeekMessage(Msg, 0, 0, 0, PM_NOREMOVE);

        ResetEvent(hTimer);
        WaitResult := JwMsgWaitForMultipleObjects([Handle, SyncEvent, hTimer], False, 1000, QS_SENDMESSAGE);
        CheckThreadError(WaitResult <> WAIT_FAILED);

        if WaitResult = WAIT_OBJECT_0 + 1 then
          CheckSynchronize;
        if WaitResult = WAIT_OBJECT_0 + 2 then
        begin
          result := WAIT_TIMEOUT;
          exit;
        end;
      until WaitResult = WAIT_OBJECT_0;
    finally
      if hTimer <> INVALID_HANDLE_VALUE then
        CloseHandle(hTimer);
    end;
  end
  else
    WaitForSingleObject(Handle, TimeOut);

  CheckThreadError(GetExitCodeThread(Handle, Result));
end;

initialization

  {
  S := LoadLocalizedString(50005, LANG_NEUTRAL, SUBLANG_NEUTRAL);
  S := LoadLocalizedString(50005, LANG_ENGLISH, SUBLANG_NEUTRAL, 0);
  S := LoadLocalizedString(50005, LANG_NEUTRAL, SUBLANG_SYS_DEFAULT);
  if s = '' then;
                       }
{  SetLength(Indexes,20);
  for i := 1 to 20 do
    Indexes[i-1] := 50000+i;
  SA := LoadLocalizedStringArray(Indexes,MAKELANGID(LANG_NEUTRAL,  SUBLANG_SYS_DEFAULT),0);
 }

{$IFDEF FullDebugMode}
  InternalMemArray := TList.Create;
{$ENDIF}

finalization
{$IFDEF FullDebugMode}
   DeleteInternalMemArray;
{$ENDIF}

end.
