# java-tools.nvim 🧙🫘
## Why do I need java-tools?
Ever feel left out of all the intelliJ fun? Want to perform Java development tasks quickly?
java-tools provides a set of user freindly tools that give neovim useful Java functionality.

## Installation
[lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
    "DylanBarratt/java-tools.nvim",
    ft = "Java" -- lazy load plugin to open with Java file type
    opts = {
        testDirectory = string,
        generateTest = GenerateTestOptions, -- see Test generation
        goToTest = GoToTestOptions, -- see GoTo test
    }
}
```
*[Full options here](lua/java-tools/options.lua)*

## Features
### Test Generation 🧪
Tired of manually creating test files? Hate navigating the file tree to find the place for your test? The JUnit test generation command will automatically generate a new test file for the current Java class!

#### Options
```lua
generateTest = {
    enabled = true,
    template = [[
package %s;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class %sTest {

    @Test
    void testExample() {
        // TODO: Implement test
        assertTrue(true);
    }
}
    ]], -- the template used for the new file. The %s are replaced with the package and class name.
    openTest = true, -- opens the test file after creation
}
```

### GoTo Test 🎯
Clicking through a file list is slow! Navigate directly to the test file for the current class. GoTo Test provides a list of files testing the current class or the option to generate a new test (using generateTest settings).

#### Options
```lua
goToTest = {
    enabled = true,
    generateTestEnabled = true,
}
```

## Future Features
    - better doc comments
    - indivdual test creation
    - implement interface with optional method overrides
    - write vim doc for project
    - MORE!!!
