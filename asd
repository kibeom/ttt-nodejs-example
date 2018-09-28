{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "* 과목: 프로그래밍언어론\n",
    "* 이름: 박기범\n",
    "* 학번: 20140644\n",
    "\n",
    "과제 제출시 꼭 위 세 항목을 작성해 주세요. 과제 제출은 9/27일 밤까지입니다.\n",
    "\n",
    "과제는 `re2nfa` 함수를 완성하는 것, 좀더 구체적으로는 `re2nfa`가 호출하는 `concatNFA`와 `kleeneNFA`를 완성하는 것입니다.\n",
    "\n",
    "배점은 `concatNFA` 함수 2점 `kleeneNFA` 함수 2점입니다."
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# 유한 오토마타 Finite Automata\n",
    "\n",
    "오토마타를 \"상태 기계\"(State Machine)라고도 한다. 따라서 유한 오토마타(Finte Automata; 줄여서 FA)는 \"유한 상태 기계\"(Finate State Macheime; 줄여서 FSM)라고도 한다. 여기서는 오토마타라는 이름으로 부르겠다.\n",
    "\n",
    "FA는 라벨된 방향 그래프(labeled directed graph)로 생각하면 된다. 그래프의 노드가 상태에 해당하고 화살표에 알파벳 라벨이 붙어 있으며, 하나의 시작 상태(initial state)가 있고 어러개(0개 이상)의 종료 상태(final state)가 있다. FA는 시작상태에서 화살표를 따라서 여러번 진행하여 종료상태에 도달하기까지 지나온 화살표의 라벨을 순서대로 나열한 문자열(글줄)을 받아들이는(accepts) 기계이다.\n",
    "FA는 시작상태에서 종료상태로 갈 수 있는 가능한 모든 경로에 해당하는 문자열의 집합, 즉 어떤 언어를 규정한다고 볼 수 있다.\n",
    "\n",
    "이론적으로 흥미로운 사실은 앞서 배운 정규식(RE)로 정의할 수 있는 언어와\n",
    "여기서 다루는 유한 오토마타(FA)로 규정할 수 있는 언어의 범위가 정확히 일치한다는 점이다. 즉,\n",
    " * 어떤 RE로 정의되는 언어를 규졍하는 FA를 구성할 수 있으며 \n",
    " * 어떤 FA로 규정되는 언어를 정의하는 RE를 작성할 수 있다.\n",
    "\n",
    "실용적인 관점에서는 전자가 더 흥미롭다.\n",
    "왜내하면 RE는 수학적 표기에 가깝지만 FA는 바로 알고리듬 즉 프로그램으로 작성하기에 알맞은 구조이기 때문이다.\n",
    "RE는 사람이 읽기 편한 수학적 표기법이며 어떤 성질의 언어인지 그 언어의 집합을 정의하기에 알맞은 구조이다.\n",
    "하지만 주어진 문자열이 언어에 속하는지 아닌지 검사하는 알고리듬을 어떻게 작성할지에 대해서는\n",
    "RE의 문법구조가 직접적인 힌트가 되지는 못한다.\n",
    "반면 FA는 사람이 읽기에는 좀 불친절하지만 시작상태로부터 상태전이 화살표를 따라가면 종료상태에 도달하는지 검사하는 알고리듬으로 옮기기 쉬운 명세이다.\n",
    "따라서 RE로 정의되는 언어를 규정하는 FA를 자동으로 생성하여 주어진 문자열이\n",
    "그 FA가 받아들이는 문자열인지 검사함으로써 어떤 문자열이 RE가 표현하는 언어에 속하는지 검사하는 프로그램을 작성할 수 있다.\n",
    "\n",
    "## DFA, NFA, NFA-$\\varepsilon$\n",
    "보통 형식언어 및 오토마타를 주로 다루는 교재에서는 다음과 같이 네 단계를 거쳐 변환하여 상태가 최소화된 DFA를 얻어낸다.\n",
    "\n",
    "RE $\\xrightarrow{\\qquad\\qquad}$\n",
    "NFA-$\\varepsilon$ $\\xrightarrow{\\quad\\varepsilon~전이~제거\\quad}$\n",
    "NFA $\\xrightarrow{\\qquad\\qquad}$\n",
    "DFA $\\xrightarrow{\\quad상태~최소화\\quad}$\n",
    "DFA\n",
    "\n",
    "이렇게 하면 상태가 최소화되어 효율적인 정규언어 검사기를 만들 수 있으며\n",
    "실제로 구문분석기(lexer)를 생성하는 프로그램들이 대개 이러한 방식으로 만들어져 있다.\n",
    "여기서는 RE와 NFA에 대해서만 다룰 것이므로 DFA나 NFA-$\\varepsilon$을 비롯해서 위 그림에 대한\n",
    "자세한 내용은 형식언어/오토마타/계산이론 관련 교재를 참고하여 시간이 날 때 틈틈이 스스로 공부해 두는 것이 좋다.\n",
    "참고로 DFA, NFA, NFA-$\\varepsilon$ 세 가지 종류의 FA가 규정할 수 있는 언어의 범위가 정확히 일치한다.\n",
    "그래서 표면적으로 보기에는 더 많은 기능을 가진 NFA-$\\varepsilon$로부터 $\\varepsilon$-전이 기능을 제외한 NFA로\n",
    "그리고 비결정성을 제외한 DFA로의 변환이 일반적으로 가능하다.\n",
    "\n",
    "보통 컴퓨터 관련 전공 학과에서 프로그래밍 언어나 컴파일러 등의 선수과목으로\n",
    "형식언어/오토마타/계산이론을 다루는 과목이 있는 것이 이론을 탄탄히 익히기에 바람직한데,\n",
    "아쉽게도 우리 학과에는 따로 없다. 그래서 이 과목 초반부에 최단시간 안에 함수형 프로그래밍과\n",
    "정규언어 관련 내용을 같이 익혀야 하는 상황이다.\n",
    "그러니까 단계를 줄여서 RE에서 NFA까지 그냥 한꺼번에 가고\n",
    "그 다음 단계들 없이, 즉 NFA를 DFA로 변환하지 않고 그냥 NFA 명세를 이용해 바로 실행하는 Haskell 프로그램을 작성해 보도록 하자."
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## NFA의 하스켈 타입 정의와 상태 전이 함수\n",
    "\n",
    "일반적으로 NFA를 이론적으로 설명할 때는 다섯 개의 요소로 이루어진 다음과 같은 순서쌍으로 정의한다. (참고로 DFA나 NFA-$\\epsilon$같은 다른 종류의 FA들도 비슷한 방식으로 다섯 순서쌍으로 정의된다.)\n",
    "\n",
    "$$(Q,\\Sigma,\\Delta,q_0,F)$$\n",
    "\n",
    "여기서 각각의 요소가 나타내는 바는 아래와 같다.\n",
    " * $Q$는 오토마타가 갖는 상태의 집합이다. 그래프로 표현할 때는 노드의 집합에 해당.\n",
    " * $\\Sigma$는 라벨로 사용되는 알파벳의 집합이다.\n",
    " * $\\Delta \\subseteq Q \\times \\Sigma \\times Q$는 상태 전이 관계이다. 그래프로 표현할 때는 라벨이 붙은 화살표에 해당한다.\n",
    " * $q_0 \\in Q$는 초기 상태이다.\n",
    " * $F \\subseteq Q$는 최종 상태의 집합이다. 그래프로 그릴 때는 보통 원을 이중으로 겹쳐 그린다.\n",
    "\n",
    "(위 내용을 수강생들에게 확실히 이해시키기 위해서 수업시간에 칠판에 예제를 하나 그려서 설명한다.)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 83,
   "metadata": {},
   "outputs": [],
   "source": [
    "type State = Int  -- 상태 타입은 유한 정수 타입인 Int를 쓰기로 하자\n",
    "type Label = Char -- 라벨 타입, 즉 알파벳 타입; RE와 마찬가지로 Char를 쓰기로 하자\n",
    "type Delta = [(State, Label, State)] -- 관계 집합(리스트)로 상태 전이\n",
    "\n",
    "-- 알파벳을 Char로 정했으므로 따로 표기할 필요가 없어 다섯순서쌍 데신 네순서쌍으로 NFA 정의\n",
    "type NFA = (State, Delta, State, [State]) -- (상태 최대값, 상태 전이 관계, 초기 상태, 종료 상태 집합)\n",
    "\n",
    "-- 관계 집합으로부터 상태 전이 함수 정의\n",
    "delta :: NFA -> (State -> Label -> [State])\n",
    "delta (_,ds,_,_) =\n",
    "   \\ st lb ->\n",
    "     [q | (p,l,q) <- ds, p == st, l == lb]"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 84,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/plain": [
       "[1,2]"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "[]"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "[2]"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "[]"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "-- 수업 예제\n",
    "ds = [(0,'a',1),(0,'a',2),(1,'b',2),(2,'a',1)]\n",
    "\n",
    "[q | (p,l,q) <- ds, p == 0, l == 'a']\n",
    "\n",
    "[q | (p,l,q) <- ds, p == 1, l == 'a']\n",
    "\n",
    "[q | (p,l,q) <- ds, p == 1, l == 'b']\n",
    "\n",
    "[q | (p,l,q) <- ds, p == 2, l == 'b']"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## 정규식이 표현하는 언어를 인식하는 NFA 생성\n",
    "우선 RegExGen 노트북에서 사용했떤 정규식 데이타 타입과 유틸리티 함수들을 그대로 복사해 오자."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 85,
   "metadata": {},
   "outputs": [],
   "source": [
    "import Data.List (union)\n",
    "\n",
    "data RE -- 정규식 데이타 타입\n",
    "  = Empty\n",
    "  | Epsilon\n",
    "  | Alphabet Char\n",
    "  | Concat RE RE\n",
    "  | Union RE RE\n",
    "  | Kleene RE\n",
    "  deriving Show\n",
    "\n",
    "-- 문자열을 Concat으로 이어진 정규식으로 변환해주는 유틸리티 함수\n",
    "string2re :: String -> RE\n",
    "string2re \"\" = Epsilon\n",
    "string2re s  = foldr1 Concat (map Alphabet s)\n",
    "\n",
    "import IHaskell.Display\n",
    "\n",
    "ppRE r = Display [html(formatRE r)]\n",
    "\n",
    "formatRE Empty = \"∅\"\n",
    "formatRE Epsilon = \"ε\"\n",
    "formatRE (Alphabet c) = c:[]\n",
    "formatRE (Concat r1 r2) = formatRE r1 ++ formatRE r2\n",
    "formatRE (Union r1 r2) = \"(\" ++ formatRE r1 ++ \"+\" ++ formatRE r2 ++ \")\"\n",
    "formatRE (Kleene r) = \"(\" ++ formatRE r ++ \")*\""
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 86,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/plain": [
       "Concat (Alphabet 'a') (Concat (Alphabet 'a') (Concat (Alphabet 'a') (Alphabet 'a')))"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "string2re \"aaaa\""
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 87,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/html": [
       "<style>/* Styles used for the Hoogle display in the pager */\n",
       ".hoogle-doc {\n",
       "display: block;\n",
       "padding-bottom: 1.3em;\n",
       "padding-left: 0.4em;\n",
       "}\n",
       ".hoogle-code {\n",
       "display: block;\n",
       "font-family: monospace;\n",
       "white-space: pre;\n",
       "}\n",
       ".hoogle-text {\n",
       "display: block;\n",
       "}\n",
       ".hoogle-name {\n",
       "color: green;\n",
       "font-weight: bold;\n",
       "}\n",
       ".hoogle-head {\n",
       "font-weight: bold;\n",
       "}\n",
       ".hoogle-sub {\n",
       "display: block;\n",
       "margin-left: 0.4em;\n",
       "}\n",
       ".hoogle-package {\n",
       "font-weight: bold;\n",
       "font-style: italic;\n",
       "}\n",
       ".hoogle-module {\n",
       "font-weight: bold;\n",
       "}\n",
       ".hoogle-class {\n",
       "font-weight: bold;\n",
       "}\n",
       ".get-type {\n",
       "color: green;\n",
       "font-weight: bold;\n",
       "font-family: monospace;\n",
       "display: block;\n",
       "white-space: pre-wrap;\n",
       "}\n",
       ".show-type {\n",
       "color: green;\n",
       "font-weight: bold;\n",
       "font-family: monospace;\n",
       "margin-left: 1em;\n",
       "}\n",
       ".mono {\n",
       "font-family: monospace;\n",
       "display: block;\n",
       "}\n",
       ".err-msg {\n",
       "color: red;\n",
       "font-style: italic;\n",
       "font-family: monospace;\n",
       "white-space: pre;\n",
       "display: block;\n",
       "}\n",
       "#unshowable {\n",
       "color: red;\n",
       "font-weight: bold;\n",
       "}\n",
       ".err-msg.in.collapse {\n",
       "padding-top: 0.7em;\n",
       "}\n",
       ".highlight-code {\n",
       "white-space: pre;\n",
       "font-family: monospace;\n",
       "}\n",
       ".suggestion-warning { \n",
       "font-weight: bold;\n",
       "color: rgb(200, 130, 0);\n",
       "}\n",
       ".suggestion-error { \n",
       "font-weight: bold;\n",
       "color: red;\n",
       "}\n",
       ".suggestion-name {\n",
       "font-weight: bold;\n",
       "}\n",
       "</style>(aaaa+(bb)*)"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "ppRE (Union (string2re \"aaaa\") (Kleene(string2re \"bb\")))"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 120,
   "metadata": {},
   "outputs": [],
   "source": [
    "-- RE를 NFA로 변환하는 함수 실제 6가지 각각의 경우에 대한 함수가 이후에 따로 작성되어 있다\n",
    "-- re2nfa는 초기상태가 0인 NFA를 생성하도록 한다.\n",
    "re2nfa :: RE -> NFA\n",
    "re2nfa Empty = emptyNFA\n",
    "re2nfa Epsilon = epsilonNFA\n",
    "re2nfa (Alphabet c) = alphaNFA c\n",
    "re2nfa (Concat r1 r2) = concatNFA (re2nfa r1) (re2nfa r2)\n",
    "re2nfa (Union r1 r2) = unionNFA (re2nfa r1) (re2nfa r2)\n",
    "re2nfa (Kleene r) = kleeneNFA (re2nfa r)\n",
    "\n",
    "-- Emtpy 정규식에 해당하는 NFA 생성\n",
    "emptyNFA :: NFA\n",
    "emptyNFA = (0,[],0,[])\n",
    "-- Epsilon 정규식에 해당하는 NFA 생성\n",
    "epsilonNFA :: NFA\n",
    "epsilonNFA = (0,[],0,[0])\n",
    "-- Alphabet c 정규식에 해당하는 NFA 생성\n",
    "alphaNFA :: Label -> NFA\n",
    "alphaNFA c = (1,[(0,c,1)],0,[1])\n",
    "\n",
    "-- 기존의 nfa로 새로운 nfa를 만들어내는 귀납적 경우를 정의하기 위한 도우미 함수\n",
    "mapNFAstate :: (State -> State) -> NFA -> NFA\n",
    "mapNFAstate f (m,ds,s,qs) = (f m, [(f p, c, f q) | (p,c,q)<-ds], f s, map f qs)\n",
    "\n",
    "{-\n",
    "-- 버그가 있는 unionNFA 정의; 언뜻 생각하면 이러면 될거같지만 버그가 있다\n",
    "unionNFA :: NFA -> NFA -> NFA\n",
    "unionNFA nfa1@(m1,ds1,_,qs1) nfa2 = (m2, union ds1 ds2, 0, union qs1 qs2)\n",
    "  where\n",
    "  (m2,ds2,_,qs2) = mapNFAstate f nfa2\n",
    "  f 0 = 0\n",
    "  f x = x + m1\n",
    "-}\n",
    "\n",
    "unionNFA :: NFA -> NFA -> NFA\n",
    "unionNFA nfa1 nfa2\n",
    "  = (m2, union ds1' ds2', 0, union qs1' qs2')\n",
    "  where\n",
    "  -- nfa1 상태를 1씩 증가\n",
    "  (m1,ds1,s1,qs1) = mapNFAstate (+1) nfa1\n",
    "  -- 1만큼 증가된 nfa1과 겹치지 않게 nfa2 상태를 증가\n",
    "  (m2,ds2,s2,qs2) = mapNFAstate (+(m1+1)) nfa2\n",
    "  ds1' = [(0,l,q) | (p,l,q)<-ds1, p==s1] `union` ds1 \n",
    "  ds2' = [(0,l,q) | (p,l,q)<-ds2, p==s2] `union` ds2\n",
    "  qs1' = if s1 `elem` qs1 then 0:qs1 else qs1\n",
    "  qs2' = if s2 `elem` qs2 then 0:qs2 else qs2\n",
    "\n",
    "concatNFA :: NFA -> NFA -> NFA\n",
    "concatNFA (m1,ds1,s1,qs1) nfa2 = (m2, ds, s1, qs)\n",
    "  where\n",
    "  (m2,ds2,s2,qs2) = mapNFAstate (+(m1+1)) nfa2\n",
    "  ds = [(e,l,q) | (p,l,q)<-ds2, e<-qs1]`union` (ds1 `union` ds2) \n",
    "  qs = if s2 `elem` qs2 then qs2 else qs2 -- 알아서 잘 변경\n",
    "\n",
    "kleeneNFA :: NFA -> NFA\n",
    "kleeneNFA (m,ds,s,qs) = (m, ds', s, qs')\n",
    "  where\n",
    "  ds' = [(e, l, q) | (p, l, q)<-ds, e<-qs] `union` ds\n",
    "  qs' = [s] `union` qs\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 121,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/plain": [
       "(1,[(0,'a',1)],0,[1])"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/html": [
       "<style>/* Styles used for the Hoogle display in the pager */\n",
       ".hoogle-doc {\n",
       "display: block;\n",
       "padding-bottom: 1.3em;\n",
       "padding-left: 0.4em;\n",
       "}\n",
       ".hoogle-code {\n",
       "display: block;\n",
       "font-family: monospace;\n",
       "white-space: pre;\n",
       "}\n",
       ".hoogle-text {\n",
       "display: block;\n",
       "}\n",
       ".hoogle-name {\n",
       "color: green;\n",
       "font-weight: bold;\n",
       "}\n",
       ".hoogle-head {\n",
       "font-weight: bold;\n",
       "}\n",
       ".hoogle-sub {\n",
       "display: block;\n",
       "margin-left: 0.4em;\n",
       "}\n",
       ".hoogle-package {\n",
       "font-weight: bold;\n",
       "font-style: italic;\n",
       "}\n",
       ".hoogle-module {\n",
       "font-weight: bold;\n",
       "}\n",
       ".hoogle-class {\n",
       "font-weight: bold;\n",
       "}\n",
       ".get-type {\n",
       "color: green;\n",
       "font-weight: bold;\n",
       "font-family: monospace;\n",
       "display: block;\n",
       "white-space: pre-wrap;\n",
       "}\n",
       ".show-type {\n",
       "color: green;\n",
       "font-weight: bold;\n",
       "font-family: monospace;\n",
       "margin-left: 1em;\n",
       "}\n",
       ".mono {\n",
       "font-family: monospace;\n",
       "display: block;\n",
       "}\n",
       ".err-msg {\n",
       "color: red;\n",
       "font-style: italic;\n",
       "font-family: monospace;\n",
       "white-space: pre;\n",
       "display: block;\n",
       "}\n",
       "#unshowable {\n",
       "color: red;\n",
       "font-weight: bold;\n",
       "}\n",
       ".err-msg.in.collapse {\n",
       "padding-top: 0.7em;\n",
       "}\n",
       ".highlight-code {\n",
       "white-space: pre;\n",
       "font-family: monospace;\n",
       "}\n",
       ".suggestion-warning { \n",
       "font-weight: bold;\n",
       "color: rgb(200, 130, 0);\n",
       "}\n",
       ".suggestion-error { \n",
       "font-weight: bold;\n",
       "color: red;\n",
       "}\n",
       ".suggestion-name {\n",
       "font-weight: bold;\n",
       "}\n",
       "</style><img src='https://graphviz.glitch.me/graphviz?layout=dot&format=svg&mode=download&graph=digraph%20G%20%7B%20node%5Bshape%3D%22circle%22%5D%3B%20start%20%5Bshape%3D%22none%22%5D%3B%20start%20-%3E%200%3B%201%20-%3E%201%20%5Blabel%3D%22a%22%5D%3B%200%20-%3E%201%20%5Blabel%3D%22a%22%5D%3B%200%20%5Bshape%3D%22doublecircle%22%5D%3B%201%20%5Bshape%3D%22doublecircle%22%5D%3B%20%7D'/>"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "digraph G { node[shape=\"circle\"]; start [shape=\"none\"]; start -> 0; 1 -> 1 [label=\"a\"]; 0 -> 1 [label=\"a\"]; 0 [shape=\"doublecircle\"]; 1 [shape=\"doublecircle\"]; }"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "(1,[(1,'a',1),(0,'a',1)],0,[0,1])"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/html": [
       "<style>/* Styles used for the Hoogle display in the pager */\n",
       ".hoogle-doc {\n",
       "display: block;\n",
       "padding-bottom: 1.3em;\n",
       "padding-left: 0.4em;\n",
       "}\n",
       ".hoogle-code {\n",
       "display: block;\n",
       "font-family: monospace;\n",
       "white-space: pre;\n",
       "}\n",
       ".hoogle-text {\n",
       "display: block;\n",
       "}\n",
       ".hoogle-name {\n",
       "color: green;\n",
       "font-weight: bold;\n",
       "}\n",
       ".hoogle-head {\n",
       "font-weight: bold;\n",
       "}\n",
       ".hoogle-sub {\n",
       "display: block;\n",
       "margin-left: 0.4em;\n",
       "}\n",
       ".hoogle-package {\n",
       "font-weight: bold;\n",
       "font-style: italic;\n",
       "}\n",
       ".hoogle-module {\n",
       "font-weight: bold;\n",
       "}\n",
       ".hoogle-class {\n",
       "font-weight: bold;\n",
       "}\n",
       ".get-type {\n",
       "color: green;\n",
       "font-weight: bold;\n",
       "font-family: monospace;\n",
       "display: block;\n",
       "white-space: pre-wrap;\n",
       "}\n",
       ".show-type {\n",
       "color: green;\n",
       "font-weight: bold;\n",
       "font-family: monospace;\n",
       "margin-left: 1em;\n",
       "}\n",
       ".mono {\n",
       "font-family: monospace;\n",
       "display: block;\n",
       "}\n",
       ".err-msg {\n",
       "color: red;\n",
       "font-style: italic;\n",
       "font-family: monospace;\n",
       "white-space: pre;\n",
       "display: block;\n",
       "}\n",
       "#unshowable {\n",
       "color: red;\n",
       "font-weight: bold;\n",
       "}\n",
       ".err-msg.in.collapse {\n",
       "padding-top: 0.7em;\n",
       "}\n",
       ".highlight-code {\n",
       "white-space: pre;\n",
       "font-family: monospace;\n",
       "}\n",
       ".suggestion-warning { \n",
       "font-weight: bold;\n",
       "color: rgb(200, 130, 0);\n",
       "}\n",
       ".suggestion-error { \n",
       "font-weight: bold;\n",
       "color: red;\n",
       "}\n",
       ".suggestion-name {\n",
       "font-weight: bold;\n",
       "}\n",
       "</style><img src='https://graphviz.glitch.me/graphviz?layout=dot&format=svg&mode=download&graph=digraph%20G%20%7B%20node%5Bshape%3D%22circle%22%5D%3B%20start%20%5Bshape%3D%22none%22%5D%3B%20start%20-%3E%200%3B%201%20-%3E%203%20%5Blabel%3D%22b%22%5D%3B%200%20-%3E%201%20%5Blabel%3D%22a%22%5D%3B%202%20-%3E%203%20%5Blabel%3D%22b%22%5D%3B%203%20%5Bshape%3D%22doublecircle%22%5D%3B%20%7D'/>"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "digraph G { node[shape=\"circle\"]; start [shape=\"none\"]; start -> 0; 1 -> 3 [label=\"b\"]; 0 -> 1 [label=\"a\"]; 2 -> 3 [label=\"b\"]; 3 [shape=\"doublecircle\"]; }"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "(3,[(1,'b',3),(0,'a',1),(2,'b',3)],0,[3])"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "alphaNFA 'a'\n",
    "\n",
    "displayGraph (kleeneNFA (alphaNFA 'a'))\n",
    "putStr (nfa2graph (kleeneNFA (alphaNFA 'a')))\n",
    "\n",
    "kleeneNFA (alphaNFA 'a')\n",
    "\n",
    "displayGraph (concatNFA (alphaNFA 'a') (alphaNFA 'b'))\n",
    "putStr (nfa2graph (concatNFA (alphaNFA 'a') (alphaNFA 'b')))\n",
    "\n",
    "concatNFA (alphaNFA 'a') (alphaNFA 'b')"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 90,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/plain": [
       "12"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "12"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "complexnumber n = x + y\n",
    "  where\n",
    "  x = n ^ 2\n",
    "  y = n ^ 3\n",
    "\n",
    "complexnumber' n =\n",
    "  let\n",
    "    x = n ^ 2\n",
    "    y = n ^ 3\n",
    "   in\n",
    "    x + y\n",
    "\n",
    "\n",
    "complexnumber 2\n",
    "complexnumber' 2"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 91,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/plain": [
       "(0,[],0,[])"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "(0,[],0,[0])"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "(1,[(0,'a',1)],0,[1])"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "(1,[(0,'b',1)],0,[1])"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "emptyNFA\n",
    "epsilonNFA\n",
    "alphaNFA 'a'\n",
    "alphaNFA 'b'"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 92,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/plain": [
       "(1,[(0,'a',1)],0,[1])"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "(2,[(1,'a',2)],1,[2])"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "(11,[(10,'a',11)],10,[11])"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "(3,[(2,'b',3)],2,[3])"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "(4,[(0,'a',2),(1,'a',2),(0,'b',4),(3,'b',4)],0,[2,4])"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "{-\n",
    "-- 버그있는 unionNFA를 테스트하던 코드\n",
    "mapNFAstate (\\x -> case x of {0 -> 0; x -> x + 1}) (alphaNFA 'b')\n",
    "unionNFA (alphaNFA 'a') (alphaNFA 'b')\n",
    "-}\n",
    "alphaNFA 'a'\n",
    "\n",
    "mapNFAstate (+1) (alphaNFA 'a')\n",
    "mapNFAstate (+10) (alphaNFA 'a')\n",
    "\n",
    "\n",
    "mapNFAstate (+2) (alphaNFA 'b')\n",
    "\n",
    "unionNFA (alphaNFA 'a') (alphaNFA 'b')"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## NFA상태를 그래프로 나타내기\n",
    "그래프로 나타내기 위해서  툴을 사용한다. (외부 웹사이트를 이용하므로 인터넷에 연결되어 있어야 이미지가 나타납니다.)\n",
    "\n",
    "https://graphviz.glitch.me/\n",
    "\n",
    "\n",
    "해당 툴에서는 문자를 유니코드화 하여 URL로 처리하기 때문에 \n",
    "우선 알파벳과 숫자를 제외한 글자를 유니코드값으로 변환하기 위한 유틸리티 함수를 가져온다.\n",
    "\n",
    "\n",
    "https://www.rosettacode.org/wiki/URL_encoding#Haskell"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 93,
   "metadata": {},
   "outputs": [],
   "source": [
    "import qualified Data.Char as Char\n",
    "import Text.Printf\n",
    " \n",
    "encode :: Char -> String\n",
    "encode c\n",
    "  | c == ' ' = \"%20\" \n",
    "  | Char.isAlphaNum c || c `elem` \"-._~\" = [c]  \n",
    "  | c `elem` \"\\\"\" = \"%22\"\n",
    "  | otherwise = printf \"%%%02X\" c\n",
    " \n",
    "urlEncode :: String -> String\n",
    "urlEncode = concatMap encode"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "초기 상태, 상태 전이 관계, 종료 상태 집합을 인식하여 해당 툴의 형식으로 바꿔줄 함수와 \n",
    "해당 문자열을 연결하여 이미지 태그로 변환하는 함수를 생성한다."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 94,
   "metadata": {},
   "outputs": [],
   "source": [
    "import IHaskell.Display\n",
    "-- 초기 상태를 문자열로 변환하는 함수\n",
    "formatStart :: Int -> String\n",
    "formatStart p = \"start [shape=\" ++ show \"none\" ++ \"]; start -> \" ++ show p ++ \"; \"\n",
    "\n",
    "-- 상태 전이 관계를 문자열로 변환하는 함수\n",
    "formatDelta :: [(Int, Char, Int)] -> String\n",
    "formatDelta [] = \"\"\n",
    "formatDelta ((p,a,q):ds) = show p ++ \" -> \" ++ show q ++ \" [label=\" ++ show (a:\"\") ++ \"]; \" ++ formatDelta ds\n",
    "\n",
    "-- 종료 상태 집합을 문자열로 변환하는 함수\n",
    "formatFinal :: [Int] -> String\n",
    "formatFinal [] = \"\"\n",
    "formatFinal (q:qs) = show q ++ \" [shape=\" ++ show \"doublecircle\" ++ \"]; \" ++ formatFinal qs\n",
    "\n",
    "-- 위의 상태집합 함수들을 연결하는 함수\n",
    "nfa2graph (_,ds,p,qs) = \"digraph G \"\n",
    "                     ++ \"{ node[shape=\"++show \"circle\" ++\"]; \" \n",
    "                     ++    formatStart p\n",
    "                     ++    formatDelta ds\n",
    "                     ++    formatFinal qs\n",
    "                     ++ \"}\"\n",
    "\n",
    "-- 문자열을 연결해 html img 코드로 만들어 화면에 출력하는 함수\n",
    "displayGraph nfa = Display [html (\"<img src='\" ++ url ++ \"'/>\")]\n",
    "  where url = \"https://graphviz.glitch.me/graphviz?layout=dot&format=svg&mode=download&graph=\"\n",
    "           ++ urlEncode (nfa2graph nfa)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 95,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/html": [
       "<style>/* Styles used for the Hoogle display in the pager */\n",
       ".hoogle-doc {\n",
       "display: block;\n",
       "padding-bottom: 1.3em;\n",
       "padding-left: 0.4em;\n",
       "}\n",
       ".hoogle-code {\n",
       "display: block;\n",
       "font-family: monospace;\n",
       "white-space: pre;\n",
       "}\n",
       ".hoogle-text {\n",
       "display: block;\n",
       "}\n",
       ".hoogle-name {\n",
       "color: green;\n",
       "font-weight: bold;\n",
       "}\n",
       ".hoogle-head {\n",
       "font-weight: bold;\n",
       "}\n",
       ".hoogle-sub {\n",
       "display: block;\n",
       "margin-left: 0.4em;\n",
       "}\n",
       ".hoogle-package {\n",
       "font-weight: bold;\n",
       "font-style: italic;\n",
       "}\n",
       ".hoogle-module {\n",
       "font-weight: bold;\n",
       "}\n",
       ".hoogle-class {\n",
       "font-weight: bold;\n",
       "}\n",
       ".get-type {\n",
       "color: green;\n",
       "font-weight: bold;\n",
       "font-family: monospace;\n",
       "display: block;\n",
       "white-space: pre-wrap;\n",
       "}\n",
       ".show-type {\n",
       "color: green;\n",
       "font-weight: bold;\n",
       "font-family: monospace;\n",
       "margin-left: 1em;\n",
       "}\n",
       ".mono {\n",
       "font-family: monospace;\n",
       "display: block;\n",
       "}\n",
       ".err-msg {\n",
       "color: red;\n",
       "font-style: italic;\n",
       "font-family: monospace;\n",
       "white-space: pre;\n",
       "display: block;\n",
       "}\n",
       "#unshowable {\n",
       "color: red;\n",
       "font-weight: bold;\n",
       "}\n",
       ".err-msg.in.collapse {\n",
       "padding-top: 0.7em;\n",
       "}\n",
       ".highlight-code {\n",
       "white-space: pre;\n",
       "font-family: monospace;\n",
       "}\n",
       ".suggestion-warning { \n",
       "font-weight: bold;\n",
       "color: rgb(200, 130, 0);\n",
       "}\n",
       ".suggestion-error { \n",
       "font-weight: bold;\n",
       "color: red;\n",
       "}\n",
       ".suggestion-name {\n",
       "font-weight: bold;\n",
       "}\n",
       "</style><img src='https://graphviz.glitch.me/graphviz?layout=dot&format=svg&mode=download&graph=digraph%20G%20%7B%20node%5Bshape%3D%22circle%22%5D%3B%20start%20%5Bshape%3D%22none%22%5D%3B%20start%20-%3E%200%3B%200%20-%3E%200%20%5Blabel%3D%22a%22%5D%3B%200%20%5Bshape%3D%22doublecircle%22%5D%3B%20%7D'/>"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "digraph G { node[shape=\"circle\"]; start [shape=\"none\"]; start -> 0; 0 -> 0 [label=\"a\"]; 0 [shape=\"doublecircle\"]; }"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/html": [
       "<style>/* Styles used for the Hoogle display in the pager */\n",
       ".hoogle-doc {\n",
       "display: block;\n",
       "padding-bottom: 1.3em;\n",
       "padding-left: 0.4em;\n",
       "}\n",
       ".hoogle-code {\n",
       "display: block;\n",
       "font-family: monospace;\n",
       "white-space: pre;\n",
       "}\n",
       ".hoogle-text {\n",
       "display: block;\n",
       "}\n",
       ".hoogle-name {\n",
       "color: green;\n",
       "font-weight: bold;\n",
       "}\n",
       ".hoogle-head {\n",
       "font-weight: bold;\n",
       "}\n",
       ".hoogle-sub {\n",
       "display: block;\n",
       "margin-left: 0.4em;\n",
       "}\n",
       ".hoogle-package {\n",
       "font-weight: bold;\n",
       "font-style: italic;\n",
       "}\n",
       ".hoogle-module {\n",
       "font-weight: bold;\n",
       "}\n",
       ".hoogle-class {\n",
       "font-weight: bold;\n",
       "}\n",
       ".get-type {\n",
       "color: green;\n",
       "font-weight: bold;\n",
       "font-family: monospace;\n",
       "display: block;\n",
       "white-space: pre-wrap;\n",
       "}\n",
       ".show-type {\n",
       "color: green;\n",
       "font-weight: bold;\n",
       "font-family: monospace;\n",
       "margin-left: 1em;\n",
       "}\n",
       ".mono {\n",
       "font-family: monospace;\n",
       "display: block;\n",
       "}\n",
       ".err-msg {\n",
       "color: red;\n",
       "font-style: italic;\n",
       "font-family: monospace;\n",
       "white-space: pre;\n",
       "display: block;\n",
       "}\n",
       "#unshowable {\n",
       "color: red;\n",
       "font-weight: bold;\n",
       "}\n",
       ".err-msg.in.collapse {\n",
       "padding-top: 0.7em;\n",
       "}\n",
       ".highlight-code {\n",
       "white-space: pre;\n",
       "font-family: monospace;\n",
       "}\n",
       ".suggestion-warning { \n",
       "font-weight: bold;\n",
       "color: rgb(200, 130, 0);\n",
       "}\n",
       ".suggestion-error { \n",
       "font-weight: bold;\n",
       "color: red;\n",
       "}\n",
       ".suggestion-name {\n",
       "font-weight: bold;\n",
       "}\n",
       "</style><img src='https://graphviz.glitch.me/graphviz?layout=dot&format=svg&mode=download&graph=digraph%20G%20%7B%20node%5Bshape%3D%22circle%22%5D%3B%20start%20%5Bshape%3D%22none%22%5D%3B%20start%20-%3E%200%3B%20%7D'/>"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "digraph G { node[shape=\"circle\"]; start [shape=\"none\"]; start -> 0; }"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/html": [
       "<style>/* Styles used for the Hoogle display in the pager */\n",
       ".hoogle-doc {\n",
       "display: block;\n",
       "padding-bottom: 1.3em;\n",
       "padding-left: 0.4em;\n",
       "}\n",
       ".hoogle-code {\n",
       "display: block;\n",
       "font-family: monospace;\n",
       "white-space: pre;\n",
       "}\n",
       ".hoogle-text {\n",
       "display: block;\n",
       "}\n",
       ".hoogle-name {\n",
       "color: green;\n",
       "font-weight: bold;\n",
       "}\n",
       ".hoogle-head {\n",
       "font-weight: bold;\n",
       "}\n",
       ".hoogle-sub {\n",
       "display: block;\n",
       "margin-left: 0.4em;\n",
       "}\n",
       ".hoogle-package {\n",
       "font-weight: bold;\n",
       "font-style: italic;\n",
       "}\n",
       ".hoogle-module {\n",
       "font-weight: bold;\n",
       "}\n",
       ".hoogle-class {\n",
       "font-weight: bold;\n",
       "}\n",
       ".get-type {\n",
       "color: green;\n",
       "font-weight: bold;\n",
       "font-family: monospace;\n",
       "display: block;\n",
       "white-space: pre-wrap;\n",
       "}\n",
       ".show-type {\n",
       "color: green;\n",
       "font-weight: bold;\n",
       "font-family: monospace;\n",
       "margin-left: 1em;\n",
       "}\n",
       ".mono {\n",
       "font-family: monospace;\n",
       "display: block;\n",
       "}\n",
       ".err-msg {\n",
       "color: red;\n",
       "font-style: italic;\n",
       "font-family: monospace;\n",
       "white-space: pre;\n",
       "display: block;\n",
       "}\n",
       "#unshowable {\n",
       "color: red;\n",
       "font-weight: bold;\n",
       "}\n",
       ".err-msg.in.collapse {\n",
       "padding-top: 0.7em;\n",
       "}\n",
       ".highlight-code {\n",
       "white-space: pre;\n",
       "font-family: monospace;\n",
       "}\n",
       ".suggestion-warning { \n",
       "font-weight: bold;\n",
       "color: rgb(200, 130, 0);\n",
       "}\n",
       ".suggestion-error { \n",
       "font-weight: bold;\n",
       "color: red;\n",
       "}\n",
       ".suggestion-name {\n",
       "font-weight: bold;\n",
       "}\n",
       "</style><img src='https://graphviz.glitch.me/graphviz?layout=dot&format=svg&mode=download&graph=digraph%20G%20%7B%20node%5Bshape%3D%22circle%22%5D%3B%20start%20%5Bshape%3D%22none%22%5D%3B%20start%20-%3E%200%3B%200%20%5Bshape%3D%22doublecircle%22%5D%3B%20%7D'/>"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "digraph G { node[shape=\"circle\"]; start [shape=\"none\"]; start -> 0; 0 [shape=\"doublecircle\"]; }"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/html": [
       "<style>/* Styles used for the Hoogle display in the pager */\n",
       ".hoogle-doc {\n",
       "display: block;\n",
       "padding-bottom: 1.3em;\n",
       "padding-left: 0.4em;\n",
       "}\n",
       ".hoogle-code {\n",
       "display: block;\n",
       "font-family: monospace;\n",
       "white-space: pre;\n",
       "}\n",
       ".hoogle-text {\n",
       "display: block;\n",
       "}\n",
       ".hoogle-name {\n",
       "color: green;\n",
       "font-weight: bold;\n",
       "}\n",
       ".hoogle-head {\n",
       "font-weight: bold;\n",
       "}\n",
       ".hoogle-sub {\n",
       "display: block;\n",
       "margin-left: 0.4em;\n",
       "}\n",
       ".hoogle-package {\n",
       "font-weight: bold;\n",
       "font-style: italic;\n",
       "}\n",
       ".hoogle-module {\n",
       "font-weight: bold;\n",
       "}\n",
       ".hoogle-class {\n",
       "font-weight: bold;\n",
       "}\n",
       ".get-type {\n",
       "color: green;\n",
       "font-weight: bold;\n",
       "font-family: monospace;\n",
       "display: block;\n",
       "white-space: pre-wrap;\n",
       "}\n",
       ".show-type {\n",
       "color: green;\n",
       "font-weight: bold;\n",
       "font-family: monospace;\n",
       "margin-left: 1em;\n",
       "}\n",
       ".mono {\n",
       "font-family: monospace;\n",
       "display: block;\n",
       "}\n",
       ".err-msg {\n",
       "color: red;\n",
       "font-style: italic;\n",
       "font-family: monospace;\n",
       "white-space: pre;\n",
       "display: block;\n",
       "}\n",
       "#unshowable {\n",
       "color: red;\n",
       "font-weight: bold;\n",
       "}\n",
       ".err-msg.in.collapse {\n",
       "padding-top: 0.7em;\n",
       "}\n",
       ".highlight-code {\n",
       "white-space: pre;\n",
       "font-family: monospace;\n",
       "}\n",
       ".suggestion-warning { \n",
       "font-weight: bold;\n",
       "color: rgb(200, 130, 0);\n",
       "}\n",
       ".suggestion-error { \n",
       "font-weight: bold;\n",
       "color: red;\n",
       "}\n",
       ".suggestion-name {\n",
       "font-weight: bold;\n",
       "}\n",
       "</style><img src='https://graphviz.glitch.me/graphviz?layout=dot&format=svg&mode=download&graph=digraph%20G%20%7B%20node%5Bshape%3D%22circle%22%5D%3B%20start%20%5Bshape%3D%22none%22%5D%3B%20start%20-%3E%200%3B%200%20-%3E%201%20%5Blabel%3D%22a%22%5D%3B%201%20%5Bshape%3D%22doublecircle%22%5D%3B%20%7D'/>"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "digraph G { node[shape=\"circle\"]; start [shape=\"none\"]; start -> 0; 0 -> 1 [label=\"a\"]; 1 [shape=\"doublecircle\"]; }"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "aStar = (0,[(0,'a',0)],0,[0])\n",
    "bStar = (0,[(0,'b',0)],0,[0])\n",
    "displayGraph aStar\n",
    "putStr (nfa2graph aStar)\n",
    "\n",
    "displayGraph emptyNFA\n",
    "putStr (nfa2graph emptyNFA)\n",
    "\n",
    "displayGraph epsilonNFA\n",
    "putStr (nfa2graph epsilonNFA)\n",
    "\n",
    "displayGraph (alphaNFA 'a')\n",
    "putStr (nfa2graph (alphaNFA 'a'))"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 96,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/html": [
       "<style>/* Styles used for the Hoogle display in the pager */\n",
       ".hoogle-doc {\n",
       "display: block;\n",
       "padding-bottom: 1.3em;\n",
       "padding-left: 0.4em;\n",
       "}\n",
       ".hoogle-code {\n",
       "display: block;\n",
       "font-family: monospace;\n",
       "white-space: pre;\n",
       "}\n",
       ".hoogle-text {\n",
       "display: block;\n",
       "}\n",
       ".hoogle-name {\n",
       "color: green;\n",
       "font-weight: bold;\n",
       "}\n",
       ".hoogle-head {\n",
       "font-weight: bold;\n",
       "}\n",
       ".hoogle-sub {\n",
       "display: block;\n",
       "margin-left: 0.4em;\n",
       "}\n",
       ".hoogle-package {\n",
       "font-weight: bold;\n",
       "font-style: italic;\n",
       "}\n",
       ".hoogle-module {\n",
       "font-weight: bold;\n",
       "}\n",
       ".hoogle-class {\n",
       "font-weight: bold;\n",
       "}\n",
       ".get-type {\n",
       "color: green;\n",
       "font-weight: bold;\n",
       "font-family: monospace;\n",
       "display: block;\n",
       "white-space: pre-wrap;\n",
       "}\n",
       ".show-type {\n",
       "color: green;\n",
       "font-weight: bold;\n",
       "font-family: monospace;\n",
       "margin-left: 1em;\n",
       "}\n",
       ".mono {\n",
       "font-family: monospace;\n",
       "display: block;\n",
       "}\n",
       ".err-msg {\n",
       "color: red;\n",
       "font-style: italic;\n",
       "font-family: monospace;\n",
       "white-space: pre;\n",
       "display: block;\n",
       "}\n",
       "#unshowable {\n",
       "color: red;\n",
       "font-weight: bold;\n",
       "}\n",
       ".err-msg.in.collapse {\n",
       "padding-top: 0.7em;\n",
       "}\n",
       ".highlight-code {\n",
       "white-space: pre;\n",
       "font-family: monospace;\n",
       "}\n",
       ".suggestion-warning { \n",
       "font-weight: bold;\n",
       "color: rgb(200, 130, 0);\n",
       "}\n",
       ".suggestion-error { \n",
       "font-weight: bold;\n",
       "color: red;\n",
       "}\n",
       ".suggestion-name {\n",
       "font-weight: bold;\n",
       "}\n",
       "</style><img src='https://graphviz.glitch.me/graphviz?layout=dot&format=svg&mode=download&graph=digraph%20G%20%7B%20node%5Bshape%3D%22circle%22%5D%3B%20start%20%5Bshape%3D%22none%22%5D%3B%20start%20-%3E%200%3B%200%20-%3E%202%20%5Blabel%3D%22a%22%5D%3B%201%20-%3E%202%20%5Blabel%3D%22a%22%5D%3B%200%20-%3E%204%20%5Blabel%3D%22b%22%5D%3B%203%20-%3E%204%20%5Blabel%3D%22b%22%5D%3B%202%20%5Bshape%3D%22doublecircle%22%5D%3B%204%20%5Bshape%3D%22doublecircle%22%5D%3B%20%7D'/>"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "digraph G { node[shape=\"circle\"]; start [shape=\"none\"]; start -> 0; 0 -> 2 [label=\"a\"]; 1 -> 2 [label=\"a\"]; 0 -> 4 [label=\"b\"]; 3 -> 4 [label=\"b\"]; 2 [shape=\"doublecircle\"]; 4 [shape=\"doublecircle\"]; }"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/html": [
       "<style>/* Styles used for the Hoogle display in the pager */\n",
       ".hoogle-doc {\n",
       "display: block;\n",
       "padding-bottom: 1.3em;\n",
       "padding-left: 0.4em;\n",
       "}\n",
       ".hoogle-code {\n",
       "display: block;\n",
       "font-family: monospace;\n",
       "white-space: pre;\n",
       "}\n",
       ".hoogle-text {\n",
       "display: block;\n",
       "}\n",
       ".hoogle-name {\n",
       "color: green;\n",
       "font-weight: bold;\n",
       "}\n",
       ".hoogle-head {\n",
       "font-weight: bold;\n",
       "}\n",
       ".hoogle-sub {\n",
       "display: block;\n",
       "margin-left: 0.4em;\n",
       "}\n",
       ".hoogle-package {\n",
       "font-weight: bold;\n",
       "font-style: italic;\n",
       "}\n",
       ".hoogle-module {\n",
       "font-weight: bold;\n",
       "}\n",
       ".hoogle-class {\n",
       "font-weight: bold;\n",
       "}\n",
       ".get-type {\n",
       "color: green;\n",
       "font-weight: bold;\n",
       "font-family: monospace;\n",
       "display: block;\n",
       "white-space: pre-wrap;\n",
       "}\n",
       ".show-type {\n",
       "color: green;\n",
       "font-weight: bold;\n",
       "font-family: monospace;\n",
       "margin-left: 1em;\n",
       "}\n",
       ".mono {\n",
       "font-family: monospace;\n",
       "display: block;\n",
       "}\n",
       ".err-msg {\n",
       "color: red;\n",
       "font-style: italic;\n",
       "font-family: monospace;\n",
       "white-space: pre;\n",
       "display: block;\n",
       "}\n",
       "#unshowable {\n",
       "color: red;\n",
       "font-weight: bold;\n",
       "}\n",
       ".err-msg.in.collapse {\n",
       "padding-top: 0.7em;\n",
       "}\n",
       ".highlight-code {\n",
       "white-space: pre;\n",
       "font-family: monospace;\n",
       "}\n",
       ".suggestion-warning { \n",
       "font-weight: bold;\n",
       "color: rgb(200, 130, 0);\n",
       "}\n",
       ".suggestion-error { \n",
       "font-weight: bold;\n",
       "color: red;\n",
       "}\n",
       ".suggestion-name {\n",
       "font-weight: bold;\n",
       "}\n",
       "</style><img src='https://graphviz.glitch.me/graphviz?layout=dot&format=svg&mode=download&graph=digraph%20G%20%7B%20node%5Bshape%3D%22circle%22%5D%3B%20start%20%5Bshape%3D%22none%22%5D%3B%20start%20-%3E%200%3B%200%20-%3E%201%20%5Blabel%3D%22a%22%5D%3B%201%20-%3E%201%20%5Blabel%3D%22a%22%5D%3B%200%20-%3E%202%20%5Blabel%3D%22b%22%5D%3B%202%20-%3E%202%20%5Blabel%3D%22b%22%5D%3B%200%20%5Bshape%3D%22doublecircle%22%5D%3B%201%20%5Bshape%3D%22doublecircle%22%5D%3B%202%20%5Bshape%3D%22doublecircle%22%5D%3B%20%7D'/>"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "digraph G { node[shape=\"circle\"]; start [shape=\"none\"]; start -> 0; 0 -> 1 [label=\"a\"]; 1 -> 1 [label=\"a\"]; 0 -> 2 [label=\"b\"]; 2 -> 2 [label=\"b\"]; 0 [shape=\"doublecircle\"]; 1 [shape=\"doublecircle\"]; 2 [shape=\"doublecircle\"]; }"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "displayGraph (unionNFA (alphaNFA 'a') (alphaNFA 'b'))\n",
    "putStr (nfa2graph (unionNFA (alphaNFA 'a') (alphaNFA 'b')))\n",
    "\n",
    "displayGraph (unionNFA aStar bStar)\n",
    "putStr (nfa2graph (unionNFA aStar bStar))"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 97,
   "metadata": {},
   "outputs": [],
   "source": [
    "accepts :: NFA -> String -> Bool\n",
    "accepts nfa@(_,_,s,finals) str = any (`elem` finals) (steps s str) \n",
    "  where\n",
    "  step :: State -> Label -> [State]\n",
    "  step = delta nfa\n",
    "  steps :: State -> [Label] -> [State]\n",
    "  steps p []     = return p\n",
    "  steps p (c:cs) = do q <- step p c\n",
    "                      steps q cs"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 98,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/plain": [
       "False"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "True"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "True"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "False"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "False"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "False"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "False"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "False"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "nfaUnionAB = unionNFA (alphaNFA 'a') (alphaNFA 'b')\n",
    "\n",
    "accepts nfaUnionAB \"\"\n",
    "accepts nfaUnionAB \"a\"\n",
    "accepts nfaUnionAB \"b\"\n",
    "accepts nfaUnionAB \"c\"\n",
    "accepts nfaUnionAB \"aa\"\n",
    "accepts nfaUnionAB \"ab\"\n",
    "accepts nfaUnionAB \"ba\"\n",
    "accepts nfaUnionAB \"bb\""
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## 주어진 문자열이 정규식을 만족하는지 검사하는 프로그램"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 99,
   "metadata": {},
   "outputs": [],
   "source": [
    "accepts' :: RE -> String -> Bool\n",
    "accepts' re str = re2nfa re `accepts` str"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 100,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/plain": [
       "False"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "True"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "True"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "False"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "False"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "False"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "False"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "False"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "reUnionAB = Union (Alphabet 'a') (Alphabet 'b') \n",
    "\n",
    "accepts' reUnionAB \"\"\n",
    "accepts' reUnionAB \"a\"\n",
    "accepts' reUnionAB \"b\"\n",
    "accepts' reUnionAB \"c\"\n",
    "accepts' reUnionAB \"aa\"\n",
    "accepts' reUnionAB \"ab\"\n",
    "accepts' reUnionAB \"ba\"\n",
    "accepts' reUnionAB \"bb\""
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": []
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Haskell",
   "language": "haskell",
   "name": "haskell"
  },
  "language_info": {
   "codemirror_mode": "ihaskell",
   "file_extension": ".hs",
   "name": "haskell",
   "pygments_lexer": "Haskell",
   "version": "8.2.2"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 1
}
