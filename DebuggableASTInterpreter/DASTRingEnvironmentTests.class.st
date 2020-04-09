Class {
	#name : #DASTRingEnvironmentTests,
	#superclass : #TestCase,
	#instVars : [
		'aDASTRingEnvironment'
	],
	#category : 'DebuggableASTInterpreter-Tests'
}

{ #category : #packages }
DASTRingEnvironmentTests class >> packagesKernel [
	^{
	'FFI-Kernel'.
	'FFI-Pools'.
	'Announcements-Core'.
	'Colors'.
	'Collections-Abstract'.
	'Collections-Native'.
	'Collections-Sequenceable'.
	'Collections-Stack'.
	'Collections-Streams'.
	'Collections-Strings'.
	'Collections-Support'.
	'Collections-Unordered'.
	'Collections-Weak'.
	'Files'.
	'FileSystem-Path'.
	'Hermes'.
	'Kernel'.
	'Kernel-BytecodeEncoders'.
	'Network-UUID'.
	'Transcript-NonInteractive'.
	'PharoBootstrap-Initialization'.
	'RPackage-Core'.
	'Random-Core'.
	'Shift-Changes'.
	'Shift-ClassBuilder'.
	'Shift-ClassInstaller'.
	'Slot-Core'.
	'System-Announcements'.
	'System-BasicCommandLineHandler'.
	'System-CommandLine'.
	'System-Finalization'.
	'System-Hashing'.
	'System-Platforms'.
	'System-SessionManager'.
	'System-Sources'.
	'System-Support'.
	'UIManager'.
	'Zinc-Character-Encoding-Core'
	}
]

{ #category : #running }
DASTRingEnvironmentTests >> setUp [
"	| path packages |
	path := './src'.
	packages := self class packagesKernel.
	aDASTRingEnvironment := DASTRingEnvironment new initializeWithRepositoryLocatedIn: path withPackages: packages"
]

{ #category : #running }
DASTRingEnvironmentTests >> testEnvironmentInitialization [
	self skip.
	self assert: aDASTRingEnvironment isNotNil 
]
