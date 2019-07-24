%module doxygen_parsing_enums

%inline %{


	/**
	 * Testing comments before enum items
	 */
	enum SomeAnotherEnum
	{
		/**
		 * The comment for the first item
		 */
		SOME_ITEM_1,
		/**
		 * The comment for the second item
		 */
		SOME_ITEM_2,
		/**
		 * The comment for the third item
		 */
		SOME_ITEM_3
	};

	/**
	 * Testing comments after enum items
	 */
	enum SomeAnotherEnum2
	{
		SOME_ITEM_10, ///< Post comment for the first item
		SOME_ITEM_20, ///< Post comment for the second item
		SOME_ITEM_30  ///< Post comment for the third item
	};

	enum SomeEnumWithTrailingComma
	{
		SOME_ITEM_100, ///< Post comment after comma.
		SOME_ITEM_200, ///< Post comment after last comma.
	};
%}
