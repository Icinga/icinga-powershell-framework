# Use PowerShell Arrays within Icinga Config

For the [Icinga Director](https://icinga.com/docs/director/latest/) we do provide a config generator, allowing users to easily import `CheckCommands` directly into the Icinga infrastructure by using the `Director Baskets`.

Some environments how ever do not make use of the Icinga Director and therefor require to handle PowerShell arrays as well.

## PowerShell Arrays

PowerShell arrays are usually defined as `@()` or together with `[array]`. In the end, the PowerShell is now expecting a comma separated input with your values.

```powershell
-ArrayArgument 'value1', 'value2', 'value3'
```

By default Icinga is not able to push arguments in this way and therefor we require a workaround

## Icinga DSL for PowerShell arrays

As Icinga is a very powerful solution and understands certain object types like arrays, we can make use of this.

The easiest approach for integrating arguments into the PowerShell array handling, we can use the internal array handling of Icinga itself. This means from a configuration point we do not need to re-think our configuration or approach.

Let's assume we have an argument called `-Services` within our check plugin which expects the `array` type. As we just learned that Icinga does understand the array data type and we can use it inside our configuration, we will continue with this approach.

For this we will now write an Icinga DSL function and apply it to our `-Services` argument. We will use the custom variable `Icinga_Windows_Services` to store all our services we want to monitor on our service checks:

```powershell
"-Services" = {
    value = {{
        var arr = macro("$Icinga_Windows_Services$");

        if (len(arr) == 0) {
            return "$null";
        }

        return arr.join(",");
    }}
}
```

What we do here is to load the `Icinga_Windows_Services` into the variable `arr`. After that we will check if there are elements set inside the `arr` variable with `len(arr)`. If no value is inside, we will return `$null` to always set a value to the PowerShell.

Last but not least we will glue every single value inside the array together by using `arr.join(",")` and separate it with a comma.

For example if we are doing this inside your service configuration:

```
vars.Icinga_Windows_Services = [ "icinga2" ]
vars.Icinga_Windows_Services += [ "w32time" ]
```

It will automatically be rendered during the runtime as this:

```
icinga2, w32time
```
