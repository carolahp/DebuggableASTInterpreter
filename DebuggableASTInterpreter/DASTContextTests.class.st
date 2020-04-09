Class {
	#name : #DASTContextTests,
	#superclass : #TestCase,
	#instVars : [
		'context'
	],
	#category : 'DebuggableASTInterpreter-Tests'
}

{ #category : #tests }
DASTContextTests >> testContextInitialization [
	context := DASTContext new.
	self assert: context executedNodes isEmpty
]

{ #category : #stack }
DASTContextTests >> testStackPopEmpty [
	| stack |
	stack := DASTStack new.
	self should: [ stack pop ] raise: Exception
]

{ #category : #stack }
DASTContextTests >> testStackPushPop [
	| stack |
	stack := DASTStack new
		push: 3;
		push: 5;
		yourself.
	self assert: stack pop equals: 5.
	self assert: stack pop equals: 3.
]

{ #category : #stack }
DASTContextTests >> testStackPushTop [
	| stack |
	stack := DASTStack new
		push: 3;
		push: 5;
		yourself.
	self assert: stack top equals: 5.
	self assert: stack pop equals: 5.
	self assert: stack pop equals: 3.
	
]

{ #category : #stack }
DASTContextTests >> testStackPushValueLink [
	| stack |
	stack := DASTStack new
		push: (ValueLink value: 4);
		push: (ValueLink value: nil);
		yourself.
	self assert: stack pop value equals: nil.
	self assert: stack pop value equals: 4.
]
