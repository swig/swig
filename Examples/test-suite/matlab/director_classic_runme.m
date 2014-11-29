import director_classic.*

TargetLangPerson=@() subclass(Person(),'id',@(self) 'TargetLangPerson');
TargetLangChild=@() subclass(Child(),'id',@(self) 'TargetLangChild');
TargetLangGrandChild=@() subclass(GrandChild(),'id',@(self) 'TargetLangGrandChild');

% Semis - don't override id() in target language
TargetLangSemiPerson=@() subclass(Person());
TargetLangSemiChild=@() subclass(Child());
TargetLangSemiGrandChild=@() subclass(GrandChild());

% Orphans - don't override id() in C++
TargetLangOrphanPerson=@() subclass(OrphanPerson(),'id',@(self) 'TargetLangOrphanPerson');
TargetLangOrphanChild=@() subclass(OrphanChild(),'id',@(self) 'TargetLangOrphanChild');

person = Person();
director_classic_helper(person, 'Person');
clear person;

person = Child();
director_classic_helper(person, 'Child');
clear person;

person = GrandChild();
director_classic_helper(person, 'GrandChild');
clear person;

person = TargetLangPerson();
director_classic_helper(person, 'TargetLangPerson');
clear person;

person = TargetLangChild();
director_classic_helper(person, 'TargetLangChild');
clear person;

person = TargetLangGrandChild();
director_classic_helper(person, 'TargetLangGrandChild');
clear person;

% Semis - don't override id() in target language
person = TargetLangSemiPerson();
director_classic_helper(person, 'Person');
clear person;

person = TargetLangSemiChild();
director_classic_helper(person, 'Child');
clear person;

person = TargetLangSemiGrandChild();
director_classic_helper(person, 'GrandChild');
clear person;

% Orphans - don't override id() in C++
person = OrphanPerson();
director_classic_helper(person, 'Person');
clear person;

person = OrphanChild();
director_classic_helper(person, 'Child');
clear person;

person = TargetLangOrphanPerson();
director_classic_helper(person, 'TargetLangOrphanPerson');
clear person;

person = TargetLangOrphanChild();
director_classic_helper(person, 'TargetLangOrphanChild');
clear person;

