# java-tools.nvim 🧙🫘
## Why do I need java-tools?
Ever feel left out of all the intelliJ fun? Want to perform Java development tasks quickly?
java-tools provides a set of user freindly tools that give neovim useful Java functionality.

## Features
### JUnit test generation 🧪
Tired of manually creating test files? Hate navigating the file tree to find the place for your test? The JUnit test generation command will automatically generate a new test file for the current Java class!

#### Options
```lua
generateTest = {
    enabled = true,
    directory = "src/test/java/", -- the base directory test will be generated in
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
},

```

## Future Features
    - go to class test
    - better doc comments
    - indivdual test creation
    - implement interface with optional method overrides
    - MORE!!!
