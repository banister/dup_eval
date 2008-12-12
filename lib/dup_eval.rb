require 'rubygems'
require 'inline'
require 'object2module'

class Object
    inline do |builder|
        builder.prefix %{
        #define KLASS_OF(o) RCLASS(RBASIC(o)->klass)
    }

    builder.c %{
      void redirect_tbls(VALUE obj) {
        unsigned long orig_iv_tbl, orig_m_tbl;
        orig_iv_tbl = (unsigned long)ROBJECT(self)->iv_tbl;
        orig_m_tbl = (unsigned long)KLASS_OF(self)->m_tbl;
        ROBJECT(self)->iv_tbl = ROBJECT(obj)->iv_tbl;
        KLASS_OF(self)->m_tbl = KLASS_OF(obj)->m_tbl;
        rb_iv_set(self, "__orig_m_tbl__", orig_m_tbl);
        rb_iv_set(self, "__orig_iv_tbl__", orig_iv_tbl);
      }
    }

        # restore needed, or else GC will crash
    builder.c %{
      void restore_tbls() {
        KLASS_OF(self)->m_tbl = (struct st_table *)rb_iv_get(self, "__orig_m_tbl__");
        ROBJECT(self)->iv_tbl = (struct st_table *)rb_iv_get(self, "__orig_iv_tbl__");
      }
    }
    end

end

class Class
  inline do |builder|
    builder.c %{
      void redirect_tbls(VALUE class) {
        unsigned long orig_iv_tbl, orig_m_tbl;
        orig_iv_tbl = (unsigned long)RCLASS(self)->iv_tbl;
        orig_m_tbl = (unsigned long)RCLASS(self)->m_tbl;
        RCLASS(self)->iv_tbl = RCLASS(class)->iv_tbl;
        RCLASS(self)->m_tbl = RCLASS(class)->m_tbl;
        rb_iv_set(self, "__orig_iv_tbl__", orig_iv_tbl);
        rb_iv_set(self, "__orig_m_tbl__", orig_m_tbl);
      }
    }

    # restore needed, or else GC will crash
    builder.c %{
      void restore_tbls() {
        RCLASS(self)->m_tbl = (struct st_table *)rb_iv_get(self, "__orig_m_tbl__");
        RCLASS(self)->iv_tbl = (struct st_table *)rb_iv_get(self, "__orig_iv_tbl__");
      }
    }
  end
end

class Proc
    def _context
        eval('self', self)
    end
end

class Module
  def dup_eval mod, &blk
    duped_context = blk._context.dup
    # make sure the singleton class is in existence
    class << duped_context; self; end

    duped_context.redirect_tbls(blk._context)

    duped_context.gen_extend mod
    begin
      m = duped_context.is_a?(Module) ? :class_eval : :instance_eval
      duped_context.send(m, &blk)
    ensure
      duped_context.restore_tbls
    end
  end
end
