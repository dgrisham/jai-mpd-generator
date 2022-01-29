MPD_PATH :: "libmpdclient";

#run {
    set_build_options_dc(.{do_output=false});

    write_file := true;
    user_args := compiler_get_command_line_arguments();
    for user_args {
        if it == "-no_write"    write_file = false;
    }
    generate_bindings(write_file = write_file);
};

// main :: () {
//     generate_bindings();
// }

generate_bindings :: (write_file := true) {
    output_filename := "generated_mpd.jai";
    opts: Generate_Bindings_Options;
    {
        using opts;

        array_add(*libpaths, "bin");
        array_add(*libnames, "libmpdclient");
        array_add(*system_include_paths, GENERATOR_DEFAULT_SYSTEM_INCLUDE_PATH);
        // #if OS == .MACOS {
        //     // @ToDo: Determine dynamically? Customize?
        //     array_add(*system_include_paths, "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include");
        // }
        array_add(*include_paths, ".");
        array_add(*source_files,  tprint("%/client.h",   MPD_PATH));

        array_add(*extra_clang_arguments, "-x", "c");
        mimic_spacing_flags = Mimic_Spacing_Flags.GLOBAL;
        generate_foreign_library_declarations = false;
        alias_original_enum_names = false;
        generate_compile_time_struct_checks = false;

        will_print_bindings = () {
            // we'll also walk all the declarations recursively, making some
            // changes. see mpd_visitor below.
            for context.compiler.global_scope.members {
                visit_declarations(mpd_visitor, it);
            }
        };
        // get_func_args_for_printing = imgui_get_function_arg_for_printing;
    }

    bindings_builder, success := generate_bindings(opts);
    if !success     return;
    defer free_buffers(*bindings_builder);
    show_generator_results();

    if write_file {
        append(*bindings_builder, CLANG_SUFFIX);
        success = write_entire_file(output_filename, bindings_builder);
        if !success {
            log_error("Could not write generated output to \"%\"\n", output_filename);
            return;
        }
        log("\nOK! generated '%'\n", output_filename);
    }
}

#import "Basic";
#import "Bindings_Generator";
#import "BuildCpp";
#import "Compiler";
#import "File";
#import "String";
#import "System";

// modified_type_names: [..] string;

mpd_visitor :: (decl: *Declaration, parent_decl: *Declaration) -> Declaration_Visit_Result {
    // if starts_with(decl.name, "mpd_") && decl.name != "mpd_operator" {
    //    decl.output_name = advance(decl.name, 4);
    //    array_add(modified_type_names, decl.output_name);
    // }
    return .RECURSE;
}


CLANG_SUFFIX :: #string END

#if OS == .LINUX {
    #import "POSIX";
    libmpdclient :: #foreign_library "linux/libmpdclient";
}
END
