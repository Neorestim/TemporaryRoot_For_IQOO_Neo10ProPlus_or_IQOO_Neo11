import{C as e,D as t,T as n,a as r,c as i,h as a,i as o,m as s,o as c,r as l,s as u,u as d,v as f,w as p}from"./button-By95tgQy.js";function m(e,t=!0){return t&&getComputedStyle(e).getPropertyValue(`direction`).trim()===`rtl`}var h=c(r(s)),g=class extends h{get name(){return this.getAttribute(`name`)??``}set name(e){this.setAttribute(`name`,e)}get form(){return this[o].form}get labels(){return this[o].labels}constructor(){super(),this.disabled=!1,this.softDisabled=!1,this.flipIconInRtl=!1,this.href=``,this.download=``,this.target=``,this.ariaLabelSelected=``,this.toggle=!1,this.selected=!1,this.type=`submit`,this.value=``,this.flipIcon=m(this,this.flipIconInRtl),this.addEventListener(`click`,this.handleClick.bind(this))}willUpdate(){this.href&&(this.disabled=!1,this.softDisabled=!1)}render(){let e=this.href?u`div`:u`button`,{ariaLabel:t,ariaHasPopup:n,ariaExpanded:r}=this,o=t&&this.ariaLabelSelected,s=this.toggle?this.selected:a,c=a;return this.href||(c=o&&this.selected?this.ariaLabelSelected:t),i`<${e}
        class="icon-button ${d(this.getRenderClasses())}"
        id="button"
        aria-label="${c||a}"
        aria-haspopup="${!this.href&&n||a}"
        aria-expanded="${!this.href&&r||a}"
        aria-pressed="${s}"
        aria-disabled=${!this.href&&this.softDisabled||a}
        ?disabled="${!this.href&&this.disabled}"
        @click="${this.handleClickOnChild}">
        ${this.renderFocusRing()}
        ${this.renderRipple()}
        ${this.selected?a:this.renderIcon()}
        ${this.selected?this.renderSelectedIcon():a}
        ${this.href?this.renderLink():this.renderTouchTarget()}
  </${e}>`}renderLink(){let{ariaLabel:e}=this;return f`
      <a
        class="link"
        id="link"
        href="${this.href}"
        download="${this.download||a}"
        target="${this.target||a}"
        aria-label="${e||a}">
        ${this.renderTouchTarget()}
      </a>
    `}getRenderClasses(){return{"flip-icon":this.flipIcon,selected:this.toggle&&this.selected}}renderIcon(){return f`<span class="icon"><slot></slot></span>`}renderSelectedIcon(){return f`<span class="icon icon--selected"
      ><slot name="selected"><slot></slot></slot
    ></span>`}renderTouchTarget(){return f`<span class="touch"></span>`}renderFocusRing(){return f`<md-focus-ring
      part="focus-ring"
      for=${this.href?`link`:`button`}></md-focus-ring>`}renderRipple(){let e=!this.href&&(this.disabled||this.softDisabled);return f`<md-ripple
      for=${this.href?`link`:a}
      ?disabled="${e}"></md-ripple>`}connectedCallback(){this.flipIcon=m(this,this.flipIconInRtl),super.connectedCallback()}handleClick(e){if(!this.href&&this.softDisabled){e.stopImmediatePropagation(),e.preventDefault();return}}async handleClickOnChild(e){await 0,!(!this.toggle||this.disabled||this.softDisabled||e.defaultPrevented)&&(this.selected=!this.selected,this.dispatchEvent(new InputEvent(`input`,{bubbles:!0,composed:!0})),this.dispatchEvent(new Event(`change`,{bubbles:!0})))}};l(g),g.formAssociated=!0,g.shadowRootOptions={mode:`open`,delegatesFocus:!0},t([p({type:Boolean,reflect:!0})],g.prototype,`disabled`,void 0),t([p({type:Boolean,attribute:`soft-disabled`,reflect:!0})],g.prototype,`softDisabled`,void 0),t([p({type:Boolean,attribute:`flip-icon-in-rtl`})],g.prototype,`flipIconInRtl`,void 0),t([p()],g.prototype,`href`,void 0),t([p()],g.prototype,`download`,void 0),t([p()],g.prototype,`target`,void 0),t([p({attribute:`aria-label-selected`})],g.prototype,`ariaLabelSelected`,void 0),t([p({type:Boolean})],g.prototype,`toggle`,void 0),t([p({type:Boolean,reflect:!0})],g.prototype,`selected`,void 0),t([p()],g.prototype,`type`,void 0),t([p({reflect:!0})],g.prototype,`value`,void 0),t([e()],g.prototype,`flipIcon`,void 0);var _=n`:host{display:inline-flex;outline:none;-webkit-tap-highlight-color:rgba(0,0,0,0);height:var(--_container-height);width:var(--_container-width);justify-content:center}:host([touch-target=wrapper]){margin:max(0px,(48px - var(--_container-height))/2) max(0px,(48px - var(--_container-width))/2)}md-focus-ring{--md-focus-ring-shape-start-start: var(--_container-shape-start-start);--md-focus-ring-shape-start-end: var(--_container-shape-start-end);--md-focus-ring-shape-end-end: var(--_container-shape-end-end);--md-focus-ring-shape-end-start: var(--_container-shape-end-start)}:host(:is([disabled],[soft-disabled])){pointer-events:none}.icon-button{place-items:center;background:none;border:none;box-sizing:border-box;cursor:pointer;display:flex;place-content:center;outline:none;padding:0;position:relative;text-decoration:none;user-select:none;z-index:0;flex:1;border-start-start-radius:var(--_container-shape-start-start);border-start-end-radius:var(--_container-shape-start-end);border-end-start-radius:var(--_container-shape-end-start);border-end-end-radius:var(--_container-shape-end-end)}.icon ::slotted(*){font-size:var(--_icon-size);height:var(--_icon-size);width:var(--_icon-size);font-weight:inherit}md-ripple{z-index:-1;border-start-start-radius:var(--_container-shape-start-start);border-start-end-radius:var(--_container-shape-start-end);border-end-start-radius:var(--_container-shape-end-start);border-end-end-radius:var(--_container-shape-end-end)}.flip-icon .icon{transform:scaleX(-1)}.icon{display:inline-flex}.link{display:grid;height:100%;outline:none;place-items:center;position:absolute;width:100%}.touch{position:absolute;height:max(48px,100%);width:max(48px,100%)}:host([touch-target=none]) .touch{display:none}@media(forced-colors: active){:host(:is([disabled],[soft-disabled])){--_disabled-icon-color: GrayText;--_disabled-icon-opacity: 1}}
`;export{g as n,_ as t};