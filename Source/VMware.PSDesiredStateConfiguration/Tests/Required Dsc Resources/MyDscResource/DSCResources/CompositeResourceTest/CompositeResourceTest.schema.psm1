Configuration CompositeResourceTest {
    Param(
        $Value
    )

    Import-DscResource -ModuleName MyDscResource

    MyTestResource Test 
    {
        SomeVal = $Value
        Ensure = 'Present'
    }
}
